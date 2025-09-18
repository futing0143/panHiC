#!/bin/bash

# grep '只存在于 /cluster/home/futing/Project/GBM' diff.txt | cut -f3 -d ' ' > dff_midd.txt
# awk '!/SRR[0-9]+\.sra/' dff_midd.txt > diff_midd.txt

# dir1="/cluster/home/futing/Project/GBM"
# dir2="/cluster2/home/futing/Project/panCancer/GBM"
# list="/cluster/home/futing/Project/GBM/diff0826.txt"

# while read -r f1; do
#     # 计算相对路径
#     rel_path="${f1#$dir1/}"
#     f2="$dir2/$rel_path"

#     # 确保目标目录存在
# 	if [ !-d "$(dirname "$f2")" ];then
#     	mkdir -p "$(dirname "$f2")"
# 	fi
#     # 同步文件
#     rsync -avh --progress --partial "$f1" "$f2"
# done < "$list"

# rsync -avh --progress --partial /cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA_hg19/* \
# 	/cluster2/home/futing/Project/panCancer/GBM/HiC/02data/01fastq/EGA_hg19

# rsync -avh --progress --partial /cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA_orin/* \
# 	/cluster2/home/futing/Project/panCancer/GBM/HiC/02data/01fastq/EGA_orin

SOURCE="/" ## 这个不要修改, 保证WeiNa_ecDNA_bw.txt 是绝对路径
TARGET="/cluster2/home/futing/Project/panCancer/GBM" ## 这个改成目标路径

rsync -avh --progress --partial \
    --files-from=/cluster/home/futing/Project/GBM/diff0906.txt \
    "$SOURCE/" \
    "$TARGET/"