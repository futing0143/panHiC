# while read -r i
# do
#     echo "start ${i}"
#     awk 'BEGIN {OFS="\t"}
#                  (FNR==NR) {
#                      a[$NF] = $2;
#                      next;
#                  }
#                  ($NF in a) {
#                      $7 = a[$NF];
#                      print;
#                  }' "${i}/HG38_read2.bed" "${i}/merged_nodups_hg19NR.bed" > "${i}/tmp.txt"
#     echo "part2 of ${i} has been done"
#     awk 'BEGIN {OFS="\t"}
#                  (FNR==NR) {
#                      a[$NF] = $2;
#                      next;
#                  }
#                  ($NF in a) {
#                      $3 = a[$NF];
#                      print;
#                  }' "${i}/HG38_read1.bed" "${i}/tmp.txt" > "${i}/merged_nodups.txt"
#     echo "part1 of ${i} has been done"
# done < file3


# while read -r file; do
#     # echo "Processing $file"
#     # cd "$file"
#     # mv mega/aligned/merged_nodups.txt mega/aligned/merged_nodups1.txt
#     # awk '{print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$14"\t"$15"\t"$16}' mega/aligned/merged_nodups1.txt > mega/aligned/merged_nodups.txt
    
#     # # 调用 mega1.sh 脚本
#     # /cluster/home/jialu/4DN_iPSc/pipeline/extra/juicer/scripts/common/mega1.sh \
#     #     -g hg38 \
#     #     -d "$file" \
#     #     -D /cluster/home/jialu/4DN_iPSc/pipeline/extra/juicer\
#     #     -s /cluster/home/tmp/EGA/hg38_Arima.txt
#     hicConvertFormat -m /cluster/home/tmp/gaorx/GBM/GBM/${file}/mega/aligned/inter_30.hic --inputFormat hic --outputFormat cool -o /cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/EGA/${file}.mcool

# done < file3

# 指定包含文件夹名称的文件列表
file_list="file3"

# 输出文件
output_file="file3_unnum.txt"

# 清空输出文件
> "$output_file"

# 读取文件列表中的每一行，并对其执行检查
while IFS= read -r folder; do
    # 构建文件路径
    file="$folder/mega/aligned/merged_nodups1.txt"
    
    # 检查文件是否存在
    if [ -f "$file" ]; then
        echo "Checking file: $file in folder $folder"
        
        # 运行 awk 命令并追加输出到统一的输出文件
        awk -F'\t' '{
            if (!($1 ~ /^[0-9]+$/ && $3 ~ /^[0-9]+$/ && $4 ~ /^[0-9]+$/ && $5 ~ /^[0-9]+$/ && $7 ~ /^[0-9]+$/ && $8 ~ /^[0-9]+$/ && $9 ~ /^[0-9]+$/ && $12 ~ /^[0-9]+$/)) {
                print "Invalid data found in folder " $folder ": Line " NR ": " $0
            }
        }' "$file" >> "$output_file"
    else
        echo "File not found: $file"
    fi
done < "$file_list"

echo "All files checked. Results saved to $output_file"


