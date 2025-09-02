# #!/bin/bash

# 合并同类型的 ChIP 信号 存为GBM.merge_BS_detail.bed
# 鉴定E-G的互作关系，../pre.sh 与gene取交集，输出 ${name}_merged_G.bedpe 
# 鉴定E-G的互作关系，与ChIP信息取交集，输出 ${filename}_chip.bedpe
# pre.ipynb 输出 filtered_*_chip.bedpe 文件

# 绘制 Enhancer 和基因表达的调节关系

#---------------- part 1 处理meta信息
# 输出：
# new_add_futing.list
# /原始路径1	GBM	${workdir}/bedfile/文件1.bed

# new_add1.list
# /原始路径1	GBM	${workdir}/bedfile/文件1.bed	行数	addID/文件1.bed.addID
# /原始路径2	NHA	${workdir}/bedfile/文件2.bed	行数	addID/文件2.bed.addID

# bedfile/ 储存处理后的 narrowpeak 文件

# addID/*.addID 储存包含分组的 bed 文件
# chr start end group(GBM/NHA...)

# ------------- 01将narrowpeak文件改成.bed，并复制到当前文件夹下
cd /cluster/home/futing/Project/GBM/HiC/hubgene/new/H3K27ac
workdir="/cluster/home/futing/Project/GBM/HiC/hubgene/new/H3K27ac"
merge_list_file="${workdir}/file.list"  # 第一列是路径，第二列是文件类型（GBM/NHA/iPSC/NPC)
output_dir="${workdir}/bedfile"
add_id_dir="${workdir}/addID"

cat $merge_list_file | while IFS=$'\t' read -r col1 col2
do
    # 获取文件路径（第1列）
    file_path=$col1
    # 获取文件名并替换扩展名
    if [[ $file_path == *.narrowPeak ]]; then
        file_name=$(basename "$file_path")
        new_file_name="${file_name%.narrowPeak}.bed"
        new_file_path="$output_dir/$new_file_name"
        
        # 复制文件并改名
        echo "Processing ${file_path}"
        cp "$file_path" "$new_file_path"
    fi
done

# 02 将新文件地址添加到第三列 new_add_futing.list
awk -v dir=${workdir} 'BEGIN{FS=OFS="\t"} 
NR<=22 {
    new_dir = dir"/bedfile"; # 新目录路径
    # 提取文件名部分，假设文件名是路径中的最后一部分
    n = split($1, arr, "/"); # 按"/"分割路径
    file_name = arr[n]; # 获取文件名
    $3 = new_dir "/" file_name; # 拼接新的路径并赋给第三列
    gsub(/\.narrowPeak$/, ".bed", $3); # 替换扩展名
} 
NR>22 {
    $3 = $1; # 直接复制第一列到第三列
} 
{ print }' ${merge_list_file} \
    > ${workdir}/new_add_futing.list


# 04 添加行数 存为new_add1.list ???why doing this
awk -F'\t' '{ 
  # 读取第3列（文件路径）
  cmd = "wc -l < " $3; 
  cmd | getline num_lines; 
  close(cmd); 
  # 打印原始行，并添加计算出的行数
  print $0 "\t" num_lines 
}' ${workdir}/new_add_futing.list \
    > tmp && mv tmp ${workdir}/new_add1.list

# #05 add cell type to each bed file
# 添加ID到bed文件后
IFS=$'\t'
while read samplefile; do
    # get file name
    sfiles=($samplefile)
    file=${sfiles[2]}
    filename=$(basename $file)
    output_path="addID/${filename}.addID"
    # 传入前三列和new_add_futing.list的第四列(sample名)（手打的）
    cut -f1-3 $file |awk -v T=${sfiles[4]} '{print $0"\t"T}' > ${workdir}/addID/${filename}.addID 
    echo -e "${samplefile}\t${output_path}" >> tmp
done < ${workdir}/new_add1.list

mv tmp ${workdir}/new_add1.list
rm ${workdir}/new_add_futing.list



#---------------------- 合并同组的bed文件

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


##09 bed转bigwig
for i in GBM NHA iPSC NPC; do
    # bedtools genomecov -i merge/${i}.merge_BS_detail.bed -g /cluster/home/futing/ref_genome/hg38_25.genome \
    #     -bg > merge/${i}.merge_BS_detail.bedGraph
	cut -f1-3,5 merge/${i}.merge_BS_detail.bed > merge/${i}.merge_BS_detail.bedGraph
    bedGraphToBigWig merge/${i}.merge_BS_detail.bedGraph /cluster/home/futing/ref_genome/hg38_25.genome \
        merge/${i}.merge_BS_detail.bw
done


# ----------------- gene overlap and convert format
# 输入 ${name}_merged_G.bedpe 来自 /cluster/home/futing/Project/GBM/HiC/hubgene/new/geneOverlap/pre.sh

# 08 merged_G和H3K27ac取交集
# 输出 _chip.bedpe （作为 ./pre.ipynb的输入）

geneOverdir=/cluster/home/futing/Project/GBM/HiC/hubgene/new/geneOverlap
for i in NHA iPSC GBM NPC; do
  file=${geneOverdir}/${i}_Gover.bedpe
  # 执行 pairToBed 并格式化输出
  pairToBed -a "$file" -b merge/${i}.merge_BS_detail.bed  > merge/"${i}_chip.bedpe"
  echo "Processed: ${i} -> ${i}_chip.bedpe"
done


# ------ enhancer region
# # ##10 提取过滤后bedpe中的E区域
input_dir="${workdir}/merge"
output_dir="${workdir}/motif"
output_suffix="_Enhanceronly.bed"

# filtered_*_chip.bedpe 来源于 ./pre.ipynb
# 出基因和增强子有且只有一个与锚点交集的行
# 遍历目录下所有 filtered_*_chip.bedpe 文件

for file in "$input_dir"/filtered_*_chip.bedpe; do
    # 提取文件名前缀
    base_name=$(basename "$file" .bedpe)
    output_file="${output_dir}/${base_name}${output_suffix}"

    # 使用 awk 处理文件
    awk '{
        count = NR
        if ($NF == "Enhancer") {
            print "peak"count"\t"$1"\t"$2"\t"$3"\t+"
        } else if ($NF == "Gene") {
            print "peak"count"\t"$4"\t"$5"\t"$6"\t+"
        }
    }' "$file" > "$output_file"

    echo "Processed: $file -> $output_file"
done


##寻找motif
for i in GBM NHA iPSC NPC; do
	mkdir ${workdir}/motif/${i}
	findMotifsGenome.pl ${workdir}/motif/filtered_${i}_chip_Enhanceronly.bed \
		hg38 ${workdir}/motif/${i}
done
