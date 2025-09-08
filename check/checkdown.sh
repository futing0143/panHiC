#!/bin/bash
set -euo pipefail
d=$1

checklist=/cluster2/home/futing/Project/panCancer/check/done_meta.txt
input=/cluster2/home/futing/Project/panCancer/new/meta/undone_down_sim.txt # 四列的输入文件
err_file="/cluster2/home/futing/Project/panCancer/check/download/err_dir${d}.txt"
> "$err_file"

# 逐组处理 cancer gse cell
cut -f1-3 "$checklist" | sort -u | while read -r cancer gse cell; do
    dir="/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}"
    
    # 输入文件中的 srr 列表
    expected=$(awk -v c="$cancer" -v g="$gse" -v cl="$cell" \
        '$1==c && $2==g && $3==cl {print $4}' "$input" | sort -u)

    # 目录里 fastq.gz 的 srr 列表
    found=$(find "$dir" -type f -name "*.fastq.gz" \
        | xargs -r -n1 basename \
        | sed 's/\.fastq\.gz$//' \
        | cut -d'_' -f1 \
        | sort -u)

    # 比较是否一致
    if [ "$expected" != "$found" ]; then
        echo -e "${cancer}\t${gse}\t${cell}" >> "$err_file"
    fi
done
