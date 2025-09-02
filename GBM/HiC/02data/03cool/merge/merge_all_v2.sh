#!/bin/bash

# 这个脚本用于顺序不同的染色体cool文件合并  
# {res}p1.txt 为正常顺序的文件名，改成我的顺序（hg38_24)
# 来源于 /cluster/home/futing/Project/GBM/HiC/02data/05file_transform/test2.py
# 每个子文件夹里的merge_all_v2都是这个文件的副本，只是修改了resolution

data_dir=/cluster/home/futing/Project/GBM/HiC/02data/03cool
resolution=(10000 50000)
for res in "${resolutions[@]}";do
    echo -e "\nProcessing resolution: ${res}...\n"

    # 这部分的是正常顺序
    while IFS= read -r line; do
        file=${data_dir}/${res}/${line}_${res}.cool
        files+=("$file")
    done < "/cluster/home/futing/Project/GBM/HiC/02data/03cool/${res}p1.txt"
    echo "Merging ${#files[@]} files..."
    cooler merge ./${res}/GBM_${res}p1.cool "${files[@]}"
    cooler dump --join ./${res}/GBM_${res}p1.cool | \
    cooler load --format bg2 /cluster/home/futing/ref_genome/hg38_24.chrom.sizes:${res} \
    - ./${res}/GBM_${res}p12.cool

    # 合并我处理的
    files=()
    while IFS= read -r line; do
        file=${data_dir}/${res}/${line}_${res}.cool
        files+=("$file")
    done < "/cluster/home/futing/Project/GBM/HiC/02data/03cool/${res}p2.txt"
    cooler merge ./${res}/GBM_${res}.cool "${files[@]}" ./${res}/GBM_${res}p12.cool
done
