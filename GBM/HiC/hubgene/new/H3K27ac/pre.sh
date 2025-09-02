#!/bin/bash

cd /cluster/home/futing/Project/GBM/HiC/hubgene/new/H3K27ac
merge_list_file="file.list"
output_dir="bedfile"
workdir="$(pwd)"
mkdir -p "$workdir/addID"
mkdir -p "$workdir/bedfile"
# 处理 narrowPeak 文件，统计行数，并生成完整信息
awk -v outdir="$workdir/bedfile" -v addid_dir="$workdir/addID" 'BEGIN{FS=OFS="\t"}
{
    file_path = $1; type = $2;
    count[type]++;
    id = type count[type];

    # 生成新的 bed 文件路径
    new_file_path = file_path;
    if (file_path ~ /.narrowPeak$/) {
        split(file_path, path_parts, "/");
        new_file_name = path_parts[length(path_parts)];
        gsub(/\.narrowPeak$/, ".bed", new_file_name);
        new_file_path = outdir "/" new_file_name;
    }



    # 生成 addID 文件路径
    split(new_file_path, path_parts, "/");
    new_file_name = path_parts[length(path_parts)];
    addid_file = addid_dir "/" new_file_name ".addID";

    # 复制并修改 narrowPeak 文件
    if (file_path ~ /.narrowPeak$/) {
        system("cp \"" file_path "\" \"" new_file_path "\"");
    }

	# 统计行数
    cmd = "wc -l < \"" new_file_path "\""; cmd | getline num_lines; close(cmd);

    # 添加 ID 到 bed 文件
    system("cut -f1-3 \"" new_file_path "\" | awk -v ID=\"" id "\" '\''{print $0 \"\t\" ID}'\'' > \"" addid_file "\"");

    print file_path, type, num_lines, new_file_path, id, addid_file;
}' "$merge_list_file" > "$workdir/final_list.txt"

# #06 merge all bed files
mkdir ./merge
process_group() {
    group=$1
    awk -F'\t' -v group="$group" '$2 == group {print $6}' new_add1.list > addID/"${group}.temp"
    sed -i 's|^addID/||' addID/"${group}.temp" 
    if [ -s addID/"${group}.temp" ]; then
        cd addID
        # 合并所有组的.temp文件到一个临时文件
        cat "${group}.temp" | xargs cat > "${group}.all"
        # 对合并后的文件进行排序
        sortBed -i "${group}.all" > "${group}.sorted"
        # 使用bedtools merge合并排序后的文件
        bedtools merge -c 4,4 -o distinct,count_distinct -i "${group}.sorted" > "../merge/${group}.merge_BS_detail.bed"
        # 删除临时文件
        rm "${group}.temp" "${group}.all" "${group}.sorted"
        cd ..
    else
        echo "No data for group $group"
    fi
}

process_group "GBM"
process_group "iPSC"
process_group "NHA"
process_group "NPC"

#GBM卡值 
mv merge/GBM.merge_BS_detail.bed merge/GBM.merge_BS_detail_old.bed
awk '$5 > 2' merge/GBM.merge_BS_detail_old.bed > merge/GBM.merge_BS_detail.bed

# ##07 bedtools coverage ${workdir}/pre.ipynb中画分布图
# # awk '{FS=OFS="\t"}{print $1,1,$2}' ~/ref_genome/hg38.genome > ~/ref_genome/hg38.genome.bed
for i in GBM NHA iPSC NPC; do
    bedtools coverage -a ~/ref_genome/hg38.genome.bed \
        -b merge/${i}.merge_BS_detail.bed > merge/${i}_chip_coverage.txt
done

# ----------------- convert format
##09 bed转bigwig
for i in GBM NHA iPSC NPC; do
    bedtools genomecov -i merge/${i}.merge_BS_detail.bed -g /cluster/home/futing/ref_genome/hg38_25.genome \
        -bg > merge/${i}.merge_BS_detail.bedGraph
    bedGraphToBigWig merge/${i}.merge_BS_detail.bedGraph /cluster/home/futing/ref_genome/hg38_25.genome \
        merge/${i}.merge_BS_detail.bw
done

