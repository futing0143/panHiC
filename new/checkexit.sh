#!/bin/bash

input_file="dumpdoneAug08.txt"  # 包含SRR编号列表的文件
output_file="missing_srr.txt"  # 输出不存在的SRR编号到该文件

# 清空或创建输出文件
> "$output_file"

# 遍历输入文件中的每个SRR编号
while IFS= read -r srr_id; do
    # 查找对应的fastq.gz文件
    if ! find ../ -name "${srr_id}*.fastq.gz" | grep -q .; then
        # 如果找不到，则将SRR编号写入输出文件
        echo "$srr_id" >> "$output_file"
    fi
done < "$input_file"

echo "检查完成,不存在的SRR编号已保存到 $output_file"