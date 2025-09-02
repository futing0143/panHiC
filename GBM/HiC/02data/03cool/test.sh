#!/bin/bash
cd /cluster/home/futing/Project/GBM/HiC/02data/04mcool
hicfile=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/GBM_onedir/A172_CPU/aligned/inter_30.hic
resolution=50000
source activate hic
hicConvertFormat -m $hicfile --inputFormat hic --outputFormat cool -o A172_CPU.mcool

sh /cluster/home/futing/Project/GBM/HiC/02data/04mcool/mcool2cool_single.sh $resolution /cluster/home/futing/Project/GBM/HiC/02data/04mcool/A172_CPU.mcool

cooltools insulation /cluster/home/futing/Project/GBM/HiC/02data/03cool/50000/A172_CPU_50000.cool -o /cluster/home/futing/Project/GBM/HiC/09insulation/50k_800k/A172_CPU_50000_insul.tsv  --ignore-diags 2 --verbose 800000

