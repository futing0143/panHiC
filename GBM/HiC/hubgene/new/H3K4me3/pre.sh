# #!/bin/bash

# 合并同类型的 ChIP 信号 存为GBM.merge_BS_detail.bed
# 鉴定E-G的互作关系，../pre.sh 与gene取交集，输出 ${name}_merged_G.bedpe 
# 鉴定E-G的互作关系，与ChIP信息取交集，输出 ${filename}_chip.bedpe
# pre.ipynb 输出 filtered_*_chip.bedpe 文件

# 绘制 H3K4me3 和基因表达的调节关系

#---------------- part 1 处理meta信息
# 输出：
# new_add_futing.list
# /原始路径1	GBM	/cluster/home/futing/Project/GBM/HiC/hubgene/new/chip/bedfile/文件1.bed

# new_add1.list
# /原始路径1	GBM	/cluster/home/futing/Project/GBM/HiC/hubgene/new/chip/bedfile/文件1.bed	行数	addID/文件1.bed.addID
# /原始路径2	NHA	/cluster/home/futing/Project/GBM/HiC/hubgene/new/chip/bedfile/文件2.bed	行数	addID/文件2.bed.addID

# bedfile/ 储存处理后的 narrowpeak 文件

# addID/*.addID 储存包含分组的 bed 文件
# chr start end group(GBM/NHA...)


# ----------- 01 add cell type to each bed file
IFS=$'\t'
while read samplefile; do
    # get file name
    sfiles=($samplefile)
    file=${sfiles[0]}
    filename=$(basename $file)
    output_path="addID/${filename}.addID"
    cut -f1-3 $file |awk -v T=${sfiles[2]} '{print $0"\t"T}' > addID/${filename}.addID 
    echo -e "${samplefile}\t${output_path}" >> /cluster/home/tmp/GBM/HiC/hubgene/new/H3K4me3/H3k4me3.list1
done < /cluster/home/tmp/GBM/HiC/hubgene/new/H3K4me3/H3k4me3.list
rm /cluster/home/tmp/GBM/HiC/hubgene/new/H3K4me3/H3k4me3.list


# -----------  merge all bed files
process_group() {
    group=$1
    # awk -F'\t' -v group="$group" '$2 == group {print $4}' H3k4me3.list1 > addID/"${group}.temp"
    # sed -i 's|^addID/||' addID/"${group}.temp" 
    if [ -s addID/"${group}.temp" ]; then
        cd addID
        # 合并所有组的.temp文件到一个临时文件
        cat $(cat "${group}.temp") > "${group}.all"
        # 对合并后的文件进行排序
        sortBed -i "${group}.all" > "${group}.sorted"
        # 使用bedtools merge合并排序后的文件
        bedtools merge -c 4,4 -o distinct,count_distinct -i "${group}.sorted" > "${group}.merge_BS_detail.bed"
        # 删除临时文件
        rm "${group}.temp" "${group}.all" "${group}.sorted"
        cd ..
    else
        echo "No data for group $group"
    fi
}

# # # 依次处理每个组
process_group "GBM"
process_group "iPSC"
process_group "NPC"
process_group "NHA"

#07 bedtools coverage /cluster/home/tmp/GBM/HiC/hubgene/new/chip/pre.ipynb中画分布图
for i in GBM NHA iPSC NPC; do
bedtools coverage -a /cluster/home/jialu/genome/hg38.chrom.sizes.bed -b addID/${i}.merge_BS_detail.bed > addID/${i}_chip_coverage.txt
done

##09 bed转bigwig
for i in GBM NHA iPSC NPC; do
bedtools genomecov -i addID/${i}.merge_BS_detail.bed -g /cluster/home/jialu/genome/hg38.chrom.sizes -bg > addID/${i}.merge_BS_detail.bedGraph
bedGraphToBigWig addID/${i}.merge_BS_detail.bedGraph /cluster/home/jialu/genome/hg38.chrom.sizes addID/${i}.merge_BS_detail.bw
done
