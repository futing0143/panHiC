#!/bin/bash
# awk -F'_' '{print $1"_"$2"_"$3"_"$4"_"$5, $6}' info.txt > info2.txt
# awk '{split($3, a, "_"); print $1,$2, a[1]"_"a[4]"_"a[9]"_"a[10]"_"a[11]}' merged.txt > merged2.txt
# join -1 1 -2 3 -o 2.1,2.2,2.3,1.2 info.txt merged2.txt > meta.txt
source /cluster/home/futing/miniforge-pypy3/etc/profile.d/conda.sh
conda activate hic
resolutions=(5000 10000 50000 100000 500000 1000000)
coolpath=/cluster/home/futing/Project/GBM/HiC/02data/03cool_order



files=()
while IFS= read -r line; do
    hicfile="/cluster/home/futing/Project/GBM/HiC/02data/01fastq/sn_m3c_hum/GSE130711/sn_m3c_${line}_tmp/Result/${line}.mcool::resolutions/10000"
    files+=("$hicfile")
done < "/cluster/home/futing/Project/GBM/HiC/02data/01fastq/snm3C/OPC.txt"

cooler merge OPC_10000.cool "${files[@]}"

cooler dump --join /cluster/home/futing/Project/GBM/HiC/02data/01fastq/snm3C/2019/OPC_10000.cool | \
cooler load --format bg2 /cluster/home/futing/ref_genome/hg38.genome:10000 \
- /cluster/home/futing/Project/GBM/HiC/02data/01fastq/snm3C/2019/OPC_fil_10000.cool

cooler balance /cluster/home/futing/Project/GBM/HiC/02data/01fastq/snm3C/2019/OPC_fil_10000.cool
