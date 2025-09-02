#!/bin/bash

source /cluster/home/futing/miniforge-pypy3/bin/activate hic
resolutions=(5000 10000 25000 50000 100000 250000 500000 1000000 2500000)
name=NHA
result_mcool=/cluster/home/futing/Project/GBM/HiC/02data/04mcool/Ctrl
target_dir=/cluster/home/futing/Project/GBM/HiC/02data/03cool_order
# 01 hic2mcool
hicConvertFormat -m /cluster/home/futing/Project/GBM/HiC/02data/01fastq/NHA/NHA.hic \
    --inputFormat hic --outputFormat cool -o $result_mcool/${name}.mcool


for resolution in "${resolutions[@]}";do
    cooler balance $result_mcool/${name}.mcool::resolutions/${resolution}
done

# 02 mcool2cool
for resolution in ${resolutions[@]};do
    /cluster/home/futing/Project/GBM/HiC/02data/05file_transform/mcool2cool_single.sh \
    ${resolution} $result_mcool/${name}.mcool $target_dir
done