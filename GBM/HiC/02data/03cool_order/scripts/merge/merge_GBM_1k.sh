#!/bin/bash

source /cluster/home/futing/miniforge-pypy3/etc/profile.d/conda.sh
conda activate HiC
data_dir=/cluster/home/tmp/GBM/HiC/02data/03cool_order
res=1000
cd ${data_dir}

echo -e "\nMerging ${res} resolution..."

# 忘了为啥，find这样写不行，还是得乖乖一个个写
# find /cluster/home/futing/Project/GBM/HiC/02data/03cool_order/1000 -name "*_1000.cool" -type f | tr '\n' ' ' \
    # | xargs cooler merge ${data_dir}/${res}/GBM_${res}.cool
# cooler balance --max-iters 800 ${data_dir}/${res}/GBM_${res}.cool
# cooler balance --max-iters 800 /cluster/home/futing/Project/GBM/HiC/02data/03cool_order/1000/U251_1000.cool


files=()
while IFS= read -r line; do
    file=/cluster/home/futing/Project/GBM/HiC/02data/03cool_order/1000/${name}_1000.cool
    files+=("$file")
done < "/cluster/home/futing/Project/GBM/HiC/02data/03cool_order/1000/name_31.txt"
cooler merge ${data_dir}/${res}/GBM_${res}_31.cool ${files[@]}
cooler balance --max-iters 800 ${data_dir}/${res}/GBM_${res}_31.cool
