#!/bin/bash

name=GBM
resolutions=(25000)
top_folder=/cluster/home/futing/Project/GBM/HiC/02data/03cool
source activate ~/anaconda3/envs/hic

cd /cluster/home/futing/Project/GBM/HiC/10loop/cooltools/GBM

for resolution in "${resolutions[@]}";do
:<<'END'
    python /cluster/home/futing/Project/GBM/HiC/10loop/cooltools/view_hg38.py \
        -i ${top_folder}/${resolution}/${name}_${resolution}.cool -n $name
END
    echo -e "\nRunning expected-cis $name...\n"
    cooltools expected-cis --clr-weight-name None --nproc 10 -o ./expected.cis.${resolution}.tsv --view ./${name}_view_hg38.tsv \
        ${top_folder}/${resolution}/${name}_${resolution}.cool
    
    echo -e "\nRunning dots for $name...\n"
    cooltools dots --nproc 10 -o ./dots.${resolution}.tsv --view ./${name}_view_hg38.tsv \
        ${top_folder}/${resolution}/${name}_${resolution}.cool \
        ./expected.cis.${resolution}.tsv
done
