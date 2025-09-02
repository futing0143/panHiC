#!/bin/bash

resolutions=(5000 10000 50000 100000 500000 1000000)
result_dir=/cluster/home/futing/Project/GBM/HiC/09insulation/50k_800k/result
data_dir=/cluster/home/futing/Project/GBM/HiC/02data/03cool_order/${resolutions[2]}
windows=800000
resolution=50000
#cat /cluster/home/futing/Project/GBM/HiC/09insulation/sup.txt | while read i;do
#for i in A172 A172_CPU;do
for i in ipsc iPSC_new NPC NPC_new;do
    name=${data_dir}/${i}_${resolutions[2]}.cool
    echo -e "Processing ${name} at ${resolutions[2]} ...\n"

    cooler dump --join /cluster/home/futing/Project/GBM/HiC/02data/04mcool/01GBM/${i}.mcool::/resolutions/${resolution} | \
        cooler load --format bg2 /cluster/home/futing/ref_genome/hg38_24.chrom.sizes:${resolution} \
        - /cluster/home/futing/Project/GBM/HiC/02data/03cool/${resolution}/${i}_${resolution}.cool 
    cooler balance /cluster/home/futing/Project/GBM/HiC/02data/03cool/${resolution}/${i}_${resolution}.cool

    cooltools insulation ${name} ${windows} -o ${result_dir}/${i}_insul.tsv  --ignore-diags 2 --verbose

done


sh /cluster/home/futing/Project/GBM/HiC/09insulation/postprocess.sh ${result_dir}/BS_50k_800k.tsv ${result_dir} 8
sh /cluster/home/futing/Project/GBM/HiC/09insulation/postprocess.sh ${result_dir}/insul_50k_800k.tsv ${result_dir} 6