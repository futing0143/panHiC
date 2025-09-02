#!/bin/bash

data_dir=/cluster/home/futing/Project/GBM/HiC/02data/03cool_KR/50000

while IFS= read -r line
do
    # 查找以当前字符串开头且以.50000.KR.cool结尾的文件，并将结果添加到数组中
    for file in $(find "$data_dir" -type f -name "${line}*.50000.KR.cool"); do
        files+=("$file")
    done
done < '/cluster/home/futing/Project/GBM/HiC/09insulation/insul_futing/name.txt'
cooler merge merged_50000.cool "${files[@]}"


cd /cluster/home/futing/Project/GBM/HiC/02data/03cool
resolutions=(5000 10000 25000 50000 100000 250000 500000 1000000 2500000)
for resolution in "${resolutions[@]}"; do
    cooler merge ./${resolution}/G208_${resolution}.cool ./${resolution}/G208R1_${resolution}.cool ./${resolution}/G208R2_${resolution}.cool
    cooler merge ./${resolution}/G213_${resolution}.cool ./${resolution}/G213R1_${resolution}.cool ./${resolution}/G213R2_${resolution}.cool
    cooler balance ./${resolution}/G208_${resolution}.cool
    cooler balance ./${resolution}/G213_${resolution}.cool
done