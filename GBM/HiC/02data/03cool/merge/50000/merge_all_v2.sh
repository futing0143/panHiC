#!/bin/bash

data_dir=/cluster/home/futing/Project/GBM/HiC/02data/03cool
res=50000
source activate ~/anaconda3/envs/hic
cd  ${data_dir}
#python /cluster/home/futing/Project/GBM/HiC/02data/05file_transform/test2.py /cluster/home/futing/Project/GBM/HiC/02data/03cool/50000 /cluster/home/futing/Project/GBM/HiC/02data/03cool/merge/50000/chrom_list_50000.csv 

# 这部分的是正常顺序
while IFS= read -r line; do
    file=${data_dir}/${res}/${line}_${res}.cool
    files+=("$file")
done < "/cluster/home/futing/Project/GBM/HiC/02data/03cool/merge/${res}/${res}p1.txt"
echo "Merging ${#files[@]} files..."
cooler merge ./${res}/GBM_${res}p1.cool "${files[@]}"
cooler dump --join ./${res}/GBM_${res}p1.cool | \
cooler load --format bg2 /cluster/home/futing/ref_genome/hg38_24.chrom.sizes:${res} \
- ./${res}/GBM_${res}p12.cool

# 合并我处理的
files=()
while IFS= read -r line; do
    file=${data_dir}/${res}/${line}_${res}.cool
    files+=("$file")
done < "/cluster/home/futing/Project/GBM/HiC/02data/03cool/merge/${res}/${res}p2.txt"

cooler merge ./${res}/GBM_${res}.cool "${files[@]}" ./${res}/GBM_${res}p12.cool
cooler balance ./${res}/GBM_${res}.cool
rm ./${res}/GBM_${res}p1.cool