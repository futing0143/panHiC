#!/bin/bash
cool_files=()
while IFS= read -r name; do
    file=/cluster/home/futing/Project/GBM/HiC/02data/03cool_order/100000/${name}_100000.cool
    cool_files+=("$file")
done < "/cluster/home/futing/Project/GBM/HiC/02data/03cool_order/name_no5.txt"

cool_norm_files=()
while IFS= read -r name; do
    file=/cluster/home/futing/Project/GBM/HiC/02data/norm/100000_no5/${name}.100000.cool
    cool_norm_files+=("$file")
done < "/cluster/home/futing/Project/GBM/HiC/02data/03cool_order/name_no5.txt"

hicNormalize -m ${cool_files[@]} \
    --normalize smallest \
    -o ${cool_norm_files[@]}