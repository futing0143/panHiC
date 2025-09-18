#!/bin/bash

# cat /cluster/home/futing/Project/GBM/GBM_0221.log | xargs -I {} sh -c 'rm {} && touch {}'
# 扫描 cluster1 家目录下 fastq/bam 文件并统计大小（单位：GB）

output="/cluster/home/futing/file_sizes.txt"
search_dir="/cluster/home/futing"

# 清空输出文件
> "$output"

# 查找并统计文件
find "$search_dir" -type f \( -name "*.fastq" -o -name "*.fastq.gz" -o -name "*.bam" \) -print0 |
while IFS= read -r -d '' file; do
    size_bytes=$(du -b "$file" | cut -f1)  # 获取字节大小
    size_gb=$(echo "scale=2; $size_bytes/1024/1024/1024" | bc)
    echo -e "${file}\t${size_gb}" >> "$output"
done

# 计算总大小
total=$(awk '{sum+=$2} END {print sum}' "$output")
echo -e "TOTAL\t${total}" >> "$output"

echo "结果已写入 $output"

