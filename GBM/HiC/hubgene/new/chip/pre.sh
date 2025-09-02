# #!/bin/bash
# # # 01将narrowpeak文件改成.bed，并复制到当前文件夹下
# merge_list_file="/cluster/home/tmp/GBM/HiC/hubgene/new/chip/old_add.list"
# output_dir="/cluster/home/tmp/GBM/HiC/hubgene/new/chip"
# awk 'NR<=22' $merge_list_file | while IFS=$'\t' read -r col1 col2
# do
#     # 获取文件路径（第1列）
#     file_path=$col1
#     # 获取文件名并替换扩展名
#     if [[ $file_path == *.narrowPeak ]]; then
#         file_name=$(basename "$file_path")
#         new_file_name="${file_name%.narrowPeak}.bed"
#         new_file_path="$output_dir/$new_file_name"
        
#         # 复制文件并改名
#         cp "$file_path" "$new_file_path"
#     fi
# done

# # # #02 将新文件地址添加到第三列
# awk 'BEGIN{FS=OFS="\t"} {
#     new_dir = "/cluster/home/tmp/GBM/HiC/hubgene/new/chip"; # 新目录路径
#     # 提取文件名部分，假设文件名是路径中的最后一部分
#     n = split($1, arr, "/"); # 按“/”分割路径
#     file_name = arr[n]; # 获取文件名
#     $3 = new_dir "/" file_name; # 拼接新的路径并赋给第三列
#     gsub(/\.narrowPeak$/, ".bed", $3); # 替换扩展名
#     print                                                   
# }' /cluster/home/tmp/GBM/HiC/hubgene/new/chip/old_add.list > /cluster/home/tmp/GBM/HiC/hubgene/new/chip/new_add.list

# # ##04 添加行数
# awk -F'\t' '{ 
#   # 读取第3列（文件路径）
#   cmd = "wc -l < " $3; 
#   cmd | getline num_lines; 
#   close(cmd); 
#   # 打印原始行，并添加计算出的行数
#   print $0 "\t" num_lines 
# }' /cluster/home/tmp/GBM/HiC/hubgene/new/chip/new_add.list > tmp && mv tmp /cluster/home/tmp/GBM/HiC/hubgene/new/chip/new_add.list1

# # #05 add cell type to each bed file
# IFS=$'\t'
# while read samplefile; do
#     # get file name
#     sfiles=($samplefile)
#     file=${sfiles[2]}
#     filename=$(basename $file)
#     output_path="addID/${filename}.addID"
# #    cut -f1-3 $file |awk -v T=${sfiles[3]} '{print $0"\t"T}' > addID/${filename}.addID 
#     echo -e "${samplefile}\t${output_path}" >> /cluster/home/tmp/GBM/HiC/hubgene/new/chip/new_add1.list
# done < /cluster/home/tmp/GBM/HiC/hubgene/new/chip/new_add.list
# rm /cluster/home/tmp/GBM/HiC/hubgene/new/chip/new_add.list

# # #06 merge all bed files
# process_group() {
#     group=$1
#     awk -F'\t' -v group="$group" '$2 == group {print $6}' new_add1.list > addID/"${group}.temp"
#     sed -i 's|^addID/||' addID/"${group}.temp" 
#     if [ -s addID/"${group}.temp" ]; then
#         cd addID
#         # 合并所有组的.temp文件到一个临时文件
#         cat $(cat "${group}.temp") > "${group}.all"
#         # 对合并后的文件进行排序
#         sortBed -i "${group}.all" > "${group}.sorted"
#         # 使用bedtools merge合并排序后的文件
#         bedtools merge -c 4,4 -o distinct,count_distinct -i "${group}.sorted" > "${group}.merge_BS_detail.bed"
#         # 删除临时文件
#         rm "${group}.temp" "${group}.all" "${group}.sorted"
#     else
#         echo "No data for group $group"
#     fi
# }

# process_group "GBM"
# process_group "iPSC"
# process_group "NHA"
# process_group "NPC"

# #GBM卡值
# awk '$5 > 2' addID/GBM.merge_BS_detail_old.bed > addID/GBM.merge_BS_detail.bed

# ##07 bedtools coverage /cluster/home/tmp/GBM/HiC/hubgene/new/chip/pre.ipynb中画分布图
# for i in GBM NHA iPSC NPC; do
# bedtools coverage -a /cluster/home/jialu/genome/hg38.chrom.sizes.bed -b addID/${i}.merge_BS_detail.bed > addID/${i}_chip_coverage.txt
# done


# # ##08 merged_G和H3K27ac取交集
# for i in ../NHA_merged_G.bedpe ../iPSC_merged_G.bedpe ../NPC_merged_G.bedpe ../GBM_merged_G.bedpe; do
#   # 获取文件名（不带扩展名）
#   filename=$(basename "$i" _merged_G.bedpe)
#   # 执行 pairToBed 并格式化输出
#   pairToBed -a "$i" -b addID/${filename}.merge_BS_detail.bed  > addID/"${filename}_chip.bedpe"
#   # 输出处理完成的文件
#   echo "Processed: ${i} -> ${filename}_chip.bedpe"
# done

# ##09 bed转bigwig
# for i in GBM NHA iPSC NPC; do
# bedtools genomecov -i addID/${i}.merge_BS_detail.bed -g /cluster/home/jialu/genome/hg38.chrom.sizes -bg > addID/${i}.merge_BS_detail.bedGraph
# bedGraphToBigWig addID/${i}.merge_BS_detail.bedGraph /cluster/home/jialu/genome/hg38.chrom.sizes addID/${i}.merge_BS_detail.bw
# done


# # ##10 提取过滤后bedpe中的E区域
input_dir="/cluster/home/tmp/GBM/HiC/hubgene/new/chip/midata"
output_dir="/cluster/home/tmp/GBM/HiC/hubgene/new/chip/motif"
output_suffix="_chip_Enhanceronly.bed"

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
mkdir /cluster/home/tmp/GBM/HiC/hubgene/new/chip/motif/${i}
findMotifsGenome.pl /cluster/home/tmp/GBM/HiC/hubgene/new/chip/motif/filtered_${i}_chip_chip_Enhanceronly.bed hg38 /cluster/home/tmp/GBM/HiC/hubgene/new/chip/motif/${i}
done
