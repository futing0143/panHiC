#!/bin/bash
source activate ~/anaconda3/envs/hic
oldcool=/cluster/home/futing/Project/GBM/HiC/02data/03cool
newcool=/cluster/home/futing/Project/GBM/HiC/02data/03cool_order
resolutions=(5000 10000 25000 50000 100000 250000 500000 1000000 2500000)

# 01 find all the unorderd cool files
for resolution in ${resolutions[@]};do
    cat /cluster/home/futing/Project/GBM/HiC/02data/04mcool/name_all.txt | while read name;do
        echo -e "Processing ${name} at ${resolution} resolution..."
        python /cluster/home/futing/Project/GBM/HiC/02data/05file_transform/compare_chr.py \
            ${newcool}/${resolution}/${name}_${resolution}.cool >> ${newcool}/${resolution}.txt
        # 之前是 oldcool    
    done
done