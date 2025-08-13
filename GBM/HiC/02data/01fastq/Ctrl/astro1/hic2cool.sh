#!/bin/bash
cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/Astrocyte
source /cluster/home/futing/miniforge-pypy3/etc/profile.d/conda.sh
conda activate hic
mcool_dir=/cluster/home/futing/Project/GBM/HiC/02data/04mcool/Control/astro1.mcool

# hicConvertFormat -m /cluster/home/futing/Project/GBM/HiC/02data/01fastq/Astrocyte/aligned/inter_30.hic \
#     --inputFormat hic --outputFormat cool \
#     -o /cluster/home/futing/Project/GBM/HiC/02data/04mcool/Control/astro1.mcool

mcool_dir=/cluster/home/futing/Project/GBM/HiC/02data/04mcool/Control/astro1.mcool
resolutions=(1000 5000 10000 50000 100000 500000 1000000)
#resolutions=(1000 25000 250000 2500000)
target_dir=/cluster/home/futing/Project/GBM/HiC/02data/03cool_order
for res in ${resolutions[@]};do
    date
    echo -e "Processing astro1 at ${res} resolution..."
    cooler balance $mcool_dir::resolutions/${res}
    /cluster/home/futing/Project/GBM/HiC/02data/05file_transform/mcool2cool_single.sh ${res} ${mcool_dir} ${target_dir}
done

