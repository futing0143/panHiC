#!/bin/bash
# 这个脚本用于所有染色体正常的合并

data_dir=/cluster/home/futing/Project/GBM/HiC/02data/03cool
resolutions=(5000 10000 25000 50000 100000 250000 500000 1000000 2500000)

for res in "${resolutions[@]}";do
    cd /cluster/home/futing/Project/GBM/HiC/02data/03cool/${res}
    files=()
    cat '/cluster/home/futing/Project/GBM/HiC/02data/03cool/GBM.txt'| while read line;do
        file=$(find "${data_dir}/${res}" -type f -name "${line}_${res}.cool")
        files+=("$file")
        
        hicInfo -m $file >> /cluster/home/futing/Project/GBM/HiC/02data/03cool/${res}_info.txt
        cooler info $file >> /cluster/home/futing/Project/GBM/HiC/02data/03cool/${res}_cooler.txt
    done
    python /cluster/home/futing/Project/GBM/HiC/02data/05file_transform/hicInfo/hicInfo.py \
        /cluster/home/futing/Project/GBM/HiC/02data/03cool/${res}_info.txt \
        ${res}.txt _${res}.cool
    cooler merge GBM_${res}.cool "${files[@]}"
done
