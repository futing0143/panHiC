#!/bin/bash
cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/A172_CPU/aligned/re_pre
source /cluster/home/futing/miniforge-pypy3/etc/profile.d/conda.sh
conda activate hic

# hicConvertFormat -m /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/A172_CPU/aligned/re_pre/inter_30.hic \
#     --inputFormat hic --outputFormat cool \
#     -o /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/A172_CPU/aligned/re_pre/A172_CPU.mcool

mcool_dir=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/A172_CPU/aligned/re_pre/A172_CPU.mcool
resolutions=(5000 10000 50000 100000 500000 1000000)
for res in ${resolutions[@]};do
    echo -e "Processing U87_re at ${res} resolution..."
    cooler balance $mcool_dir::resolutions/${res}
    /cluster/home/futing/Project/GBM/HiC/02data/04mcool/scripts/mcool2cool_single.sh ${res} $mcool_dir
done
