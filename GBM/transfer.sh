#!/bin/bash

# grep '只存在于 /cluster/home/futing/Project/GBM' diff.txt | cut -f3 -d ' ' > dff_midd.txt
# awk '!/SRR[0-9]+\.sra/' dff_midd.txt > diff_midd.txt

dir1="/cluster/home/futing/Project/GBM"
dir2="/cluster2/home/futing/Project/panCancer/GBM"
list="/cluster/home/futing/Project/GBM/diff0824.txt"

while read -r f1; do
    # 计算相对路径
    rel_path="${f1#$dir1/}"
    f2="$dir2/$rel_path"

    # 确保目标目录存在
    mkdir -p "$(dirname "$f2")"

    # 同步文件
    rsync -avh --progress --partial "$f1" "$f2"
done < "$list"
