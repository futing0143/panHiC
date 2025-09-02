#!/bin/bash

source /cluster/home/futing/miniforge-pypy3/etc/profile.d/conda.sh
conda activate hic

echo -e "Converting hic to cool..."
# hicConvertFormat -m /cluster/home/futing/Project/GBM/HiC/02data/01fastq/snm3C/2019/OPC.hic \
#     --inputFormat hic --outputFormat cool \
#     -o /cluster/home/futing/Project/GBM/HiC/02data/04mcool/Control/OPC.mcool

# 03 mcool2cool
mcool_dir=/cluster/home/futing/Project/GBM/HiC/02data/04mcool/Control/OPC.mcool
resolutions=(1000 5000 10000 25000 50000 100000 250000 500000 1000000 2500000)
target_dir=/cluster/home/futing/Project/GBM/HiC/02data/03cool_order
for res in ${resolutions[@]};do
    date
    echo -e "Processing Atrocyte at ${res} resolution..."
    cooler balance --max-iters 1000 --force $mcool_dir::resolutions/${res}
    /cluster/home/futing/Project/GBM/HiC/02data/05file_transform/mcool2cool_single.sh ${res} $mcool_dir $target_dir
done