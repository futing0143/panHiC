#!/bin/bash

# 指定的路径
# base_dir="/cluster/home/tmp/gaorx/GBM/GBM"

# # 遍历指定路径下的所有子目录
# find "$base_dir" -type d | while read dir; do
# #    if [ -f "$dir/merged_nodups.txt" ]; then
#     if [ -f "$dir/merged_nodups_hg19.txt" ]; then       
#         awk '{print $6"\t"($7-1)"\t"$7"\t"NR}' "$dir/merged_nodups_hg19.txt" > "$dir/HG19_read2.bed"
#         /cluster/home/jialu/biosoft/liftOver "$dir/HG19_read2.bed" /cluster/home/jialu/biosoft/hg19ToHg38.over.chain.gz "$dir/HG38_read2.bed" "$dir/HG38_read2_unmap.bed" 

#     fi
# done


# # 遍历父目录下的所有文件夹
# find "$base_dir" -type d | while read dir; do
#     if [ -f "$dir/HG38_read2.bed" ] && [ -f "$dir/merged_nodups_hg19NR.bed" ]; then
#             awk 'BEGIN {OFS="\t"}
#                  (FNR==NR) {
#                      a[$NF] = $2;
#                      next;
#                  }
#                  ($NF in a) {
#                      $7 = a[$NF];
#                      print;
#                  }' "$dir/HG38_read2.bed" "$dir/merged_nodups_hg19NR.bed" > "$dir/tmp.txt"
#     fi
# done


#while read -r file; do
    # echo "Processing $file"
    # cd "$file"
    # mv mega/aligned/merged_nodups.txt mega/aligned/merged_nodups1.txt
    # awk '{print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$14"\t"$15"\t"$16}' mega/aligned/merged_nodups1.txt > mega/aligned/merged_nodups.txt
    
    # # 调用 mega1.sh 脚本
    # /cluster/home/jialu/4DN_iPSc/pipeline/extra/juicer/scripts/juicer.sh \
    # -S final \
    # -g hg38 \
    # -d "$file/mega" \
    # -p /cluster/home/jialu/4DN_iPSc/pipeline/ref/hg38/hg38.genome \
    # -y /cluster/home/tmp/EGA/hg38_Arima.txt \
    # -z /cluster/home/jialu/4DN_iPSc/pipeline/ref/hg38/hg38.fa \
    # -D /cluster/home/jialu/4DN_iPSc/pipeline/extra/juicer 
#    hicConvertFormat -m /cluster/home/tmp/gaorx/GBM/GBM/${file}/mega/aligned/inter_30.hic --inputFormat hic --outputFormat cool -o /cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/EGA/${file}.mcool

#done < file2



# base_dir="/cluster/home/tmp/gaorx/GBM/GBM"

# # 遍历指定路径下的所有子目录
# find "$base_dir" -type d | while read dir; do
#     if [ -f "$dir/merged_nodups_hg19.txt" ]; then   
#         awk '{print $0, NR}' "$dir/merged_nodups_hg19.txt" > "$dir/merged_nodups_hg19NR.bed"     
#         awk '{print $2"\t"($3-1)"\t"$3}' "$dir/merged_nodups_hg19NR.bed" > "$dir/HG19_read1.bed"
#         awk '{print $6"\t"($7-1)"\t"$7}' "$dir/merged_nodups_hg19NR.bed" > "$dir/HG19_read2.bed"
#         /cluster/home/jialu/biosoft/liftOver "$dir/HG19_read1.bed" /cluster/home/jialu/biosoft/hg19ToHg38.over.chain.gz "$dir/HG38_read1.bed" "$dir/HG38_read1_unmap.bed" 
#         /cluster/home/jialu/biosoft/liftOver "$dir/HG19_read2.bed" /cluster/home/jialu/biosoft/hg19ToHg38.over.chain.gz "$dir/HG38_read2.bed" "$dir/HG38_read2_unmap.bed" 

#     fi
# done

while read -r file
do
   i="$file/aligned"
    echo "start ${i}"
    awk 'BEGIN {OFS=" "}
                 (FNR==NR) {
                     a[$NF] = $2;
                     next;
                 }
                 ($NF in a) {
                     $7 = a[$NF];
                     print;
                 }' "${i}/HG38_read2.bed" "${i}/merged_nodups_hg19NR.bed" > "${i}/tmp_new.txt"
    echo "part2 of ${i} has been done"
    awk 'BEGIN {OFS=" "}
                 (FNR==NR) {
                     a[$NF] = $2;
                     next;
                 }
                 ($NF in a) {
                     $3 = a[$NF];
                     print;
                 }' "${i}/HG38_read1.bed" "${i}/tmp_new.txt" > "${i}/merged_nodups_new.txt"
    echo "part1 of ${i} has been done"
    cut -d' ' -f1-16 "${i}/merged_nodups_new.txt" > /cluster/home/tmp/gaorx/GBM/GBM/P524.SF12681v9_new/mega1/merged_nodups.txt
    /cluster/home/jialu/4DN_iPSc/pipeline/extra/juicer/scripts/common/mega1.sh -d /cluster/home/tmp/gaorx/GBM/GBM/P524.SF12681v9_new  -g /cluster/home/jialu/4DN_iPSc/pipeline/ref/hg38/hg38.genome -s /cluster/home/tmp/EGA/hg38_Arima.txt -D /cluster/home/jialu/4DN_iPSc/pipeline/extra/juicer 

done < test


# awk -F'\t' '{
#     if (!($1 ~ /^[0-9]+$/ && $3 ~ /^[0-9]+$/ && $4 ~ /^[0-9]+$/ && $5 ~ /^[0-9]+$/ && $7 ~ /^[0-9]+$/ && $8 ~ /^[0-9]+$/ && $9 ~ /^[0-9]+$/ && $12 ~ /^[0-9]+$/)) {
#         print "Invalid data found on line " NR ": " $0
#     }
# }' /cluster/home/tmp/gaorx/GBM/GBM/P524.SF12681v9_new/mega/aligned/merged_nodups1.txt >> P524.SF12681v9_unnum.txt

