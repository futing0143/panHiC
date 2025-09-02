#!/bin/bash
data_dir=/cluster/home/futing/Project/GBM/HiC/02data/03cool
:<<'END'
find $data_dir -name '*.kr.cool' | while read i;do
    echo "Processing ${i}"
    hicInfo --matrices $i
done
END

resolutions=(5000 10000 25000 50000 100000 250000 500000 1000000)
for res in ${resolutions[@]};do
    echo "Processing $data_dir/${res}/GBM_${res}.cool..."
    hicInfo --matrices $data_dir/${res}/GBM_${res}.cool >> /cluster/home/futing/Project/GBM/HiC/02data/05file_transform/hicInfo/GBM.log
done

python /cluster/home/futing/Project/GBM/HiC/02data/05file_transform/hicInfo/hicInfo.py \
    /cluster/home/futing/Project/GBM/HiC/02data/05file_transform/hicInfo/GBM.log \
    /cluster/home/futing/Project/GBM/HiC/02data/05file_transform/hicInfo/GBM.hicInfo.txt \
    '.'