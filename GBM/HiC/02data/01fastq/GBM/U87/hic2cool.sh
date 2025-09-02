#!/bin/bash
cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U87
source /cluster/home/futing/miniforge-pypy3/etc/profile.d/conda.sh
conda activate hic

hicConvertFormat -m /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U87/aligned/inter_30.hic \
    --inputFormat hic --outputFormat cool \
    -o /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U87/U87.mcool
mcool_dir=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U87/U87.mcool

for res in ${resolutions[@]};do
    echo -e "Processing U87 at ${res} resolution..."
    cooler balance $mcool_dir::resolutions/${res}
    /cluster/home/futing/Project/GBM/HiC/02data/04mcool/scripts/mcool2cool_single.sh ${res} $mcool_dir
done
