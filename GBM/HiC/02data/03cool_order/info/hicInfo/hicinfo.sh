#!/bin/bash
data_dir=/cluster/home/futing/Project/GBM/HiC/02data/03cool
resolutions=(5000 10000 25000 50000 100000 250000 500000 1000000)
for res in ${resolutions[@]};do
    for i in ipsc iPSC_new NPC NPC_new pHGG;do

        echo "Processing $data_dir/${res}/${i}_${res}.cool..."
        hicInfo --matrices $data_dir/${res}/${i}_${res}.cool \
        >> /cluster/home/futing/Project/GBM/HiC/02data/03cool/info/${res}_con.log
    done
    python /cluster/home/futing/Project/GBM/HiC/02data/05file_transform/hicInfo/hicInfo.py \
    /cluster/home/futing/Project/GBM/HiC/02data/03cool/info/${res}_con.log \
    /cluster/home/futing/Project/GBM/HiC/02data/03cool/info/${res}_con \
    '.'

done

