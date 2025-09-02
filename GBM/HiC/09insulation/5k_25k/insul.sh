#!/bin/bash
i=$1
resolutions=(5000 10000 50000 100000 500000 1000000)

cd /cluster/home/futing/Project/GBM/HiC/09insulation/5k_25k
data_dir=/cluster/home/futing/Project/GBM/HiC/02data/03cool_order/${resolutions[0]}
result_dir=/cluster/home/futing/Project/GBM/HiC/09insulation/5k_25k/result
mkdir -p ${result_dir}
source activate HiC


# for i in GBM;do

name=${data_dir}/${i}_${resolutions[0]}.cool
echo -e "Processing ${name} ...\n"

cooltools insulation ${name} 25000 -o ${result_dir}/${i}_insul.tsv  --ignore-diags 2 --verbose



# /cluster/home/futing/Project/GBM/HiC/09insulation/postprocess.sh GBM_merged.tsv ${result_dir} 6
paste <(cut -f1-3 "${result_dir}/42MGBA_insul.tsv") GBM_merged.tsv > GBM_merged.bed
