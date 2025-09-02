#!/bin/bash
# 设置文件夹路径和基因组文件路径
directory_path="/path/to/your/directory"
genome_file="/path/to/hg38.genome"

# 将 hg38.genome 的内容读入数组
mapfile -t chromosomes < "$genome_file"

# 遍历文件夹中的所有 tags.tsv 文件
find "$directory_path" -type f -name "*tags.tsv" | while read -r file; do
    # 获取文件名（不包括路径和后缀）
    filename=$(basename "$file" .tags.tsv)

    # 检查文件名是否在 hg38.genome 中
    if printf '%s\n' "${chromosomes[@]}" | grep -qx "$filename"; then
        echo "保留文件: $file"
    else
        echo "删除文件: $file"
        rm "$file"
    fi
done
