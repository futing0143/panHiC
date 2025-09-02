#!/bin/bash

resolutions=(5000 10000 50000 100000 500000 1000000)
result_dir=/cluster/home/futing/Project/GBM/HiC/09insulation/50k_800k/result
data_dir=/cluster/home/futing/Project/GBM/HiC/02data/03cool_order/${resolutions[2]}
windows=800000
resolution=50000

#cat /cluster/home/futing/Project/GBM/HiC/09insulation/sup.txt | while read i;do
for i in GBM;do
    name=${data_dir}/${i}_${resolutions[2]}.cool
    echo -e "Processing ${name} ...\n"
    cooltools insulation ${name} ${windows} -o ${result_dir}/${i}_insul.tsv  --ignore-diags 2 --verbose

done


sh /cluster/home/futing/Project/GBM/HiC/09insulation/postprocess.sh BS_50k_sup_800k.tsv ${result_dir} 8
sh /cluster/home/futing/Project/GBM/HiC/09insulation/postprocess.sh insul_50k_sup_800k.tsv ${result_dir} 6