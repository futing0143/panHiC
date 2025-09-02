# #01 add cell type to each bed file
IFS=$'\t'
while read samplefile; do
    # get file name
    sfiles=($samplefile)
    file=${sfiles[0]}
    filename=$(basename $file)
    output_path="addID/${filename}.addID"
    cut -f1-3 $file |awk -v T=${sfiles[2]} '{print $0"\t"T}' > addID/${filename}.addID 
    echo -e "${samplefile}\t${output_path}" >> /cluster/home/tmp/GBM/HiC/hubgene/new/CTCF/CTCF.list
done < /cluster/home/tmp/GBM/HiC/hubgene/new/CTCF/CTCF
rm /cluster/home/tmp/GBM/HiC/hubgene/new/CTCF/CTCF


#06 merge all bed files
process_group() {
    group=$1
    awk -F'\t' -v group="$group" '$2 == group {print $4}' CTCF.list > addID/"${group}.temp"
    sed -i 's|^addID/||' addID/"${group}.temp" 
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

##07 bedtools coverage /cluster/home/tmp/GBM/HiC/hubgene/new/chip/pre.ipynb中画分布图
for i in GBM iPSC NPC; do
bedtools coverage -a /cluster/home/jialu/genome/hg38.chrom.sizes.bed -b addID/${i}.merge_BS_detail.bed > addID/${i}_chip_coverage.txt
done

##09 bed转bigwig
for i in GBM iPSC NPC; do
bedtools genomecov -i addID/${i}.merge_BS_detail.bed -g /cluster/home/jialu/genome/hg38.chrom.sizes -bg > addID/${i}.merge_BS_detail.bedGraph
bedGraphToBigWig addID/${i}.merge_BS_detail.bedGraph /cluster/home/jialu/genome/hg38.chrom.sizes addID/${i}.merge_BS_detail.bw
done
