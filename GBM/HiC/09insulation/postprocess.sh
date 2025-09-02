#!/bin/bash


# 合并所有 insulation 分析结果
#output_file="BS_50k_800k.tsv"
output_file=$1
result_dir=$2
id=$3

# 初始化输出文件，并添加列标题
> $output_file

# 遍历文件夹中的每个 .tsv 文件

# cat /cluster/home/futing/Project/GBM/HiC/09insulation/GBM.txt | while read i;do
#     file=${result_dir}/${i}_insul.tsv
    
#     # 将列标题添加到输出文件
#     echo -e "${i}" > temp_col.tsv
    
#     # 提取每个文件的第六列，并追加到临时文件 temp_col.tsv
#     # 6: log2_insulation_score_800000 8:boundary_strength_800000 9:is_boundary_800000
#     awk -v col="$id" 'NR > 1{print $col}' "$file" >> temp_col.tsv
    
#     # 使用 paste 将新列添加到输出文件
#     paste $output_file temp_col.tsv > temp_combined.tsv
#     mv temp_combined.tsv $output_file
# done

first_file=true
>"$output_file"
# for file in /cluster/home/futing/Project/GBM/HiC/09insulation/50k_800k/result/*_insul.tsv; do
for file in ${result_dir}/*_insul.tsv; do
    i=$(basename $file _insul.tsv)
    echo -e "${i}" > temp_col.tsv
    awk -v col="$id" 'NR > 1{print $col}' "$file" >> temp_col.tsv
    if [ "$first_file" = true ]; then
        # 避免引入空列
        cp temp_col.tsv $output_file
        first_file=false
    else
        paste $output_file temp_col.tsv > temp_combined.tsv
        mv temp_combined.tsv $output_file
    fi
done

rm temp_col.tsv

