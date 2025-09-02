#!/bin/bash

source activate ~/anaconda3/envs/hic
data_dir=/cluster/home/tmp/GBM/HiC/02data/03cool_order
resolutions=(5000 10000 25000 50000 100000 250000 500000 1000000 2500000)
cd ${data_dir}
for res in ${resolutions[@]};do
    echo -e "\nMerging ${res} resolution..."
    files=()
    while IFS= read -r line; do
        file=${data_dir}/${res}/${line}_${res}.cool
        files+=("$file")
    done < "/cluster/home/tmp/GBM/HiC/02data/03cool_order/GBM.txt"

    cooler merge ${data_dir}/${res}/GBM_${res}.cool "${files[@]}"
    cooler balance --max-iters 800 ${data_dir}/${res}/GBM_${res}.cool
done

cooler balance --max-iters 800 /cluster/home/futing/Project/GBM/HiC/02data/03cool_order/1000/U251_1000.cool