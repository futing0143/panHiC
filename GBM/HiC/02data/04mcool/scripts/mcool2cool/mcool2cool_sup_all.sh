#!/bin/bash

# 重做特定分辨率的cool文件
resolutions=(25000 250000 2500000)
top_folder=/cluster/home/futing/Project/GBM/HiC/02data/04mcool/
cool_file=/cluster/home/futing/Project/GBM/HiC/02data/03cool
source activate ~/anaconda3/envs/hic

cat name1.txt | while read prefix;do
    # 使用find命令递归搜索匹配的文件
    read -r -d '' mcool_file < <(find "$top_folder" -type f -name "$prefix.mcool" -print0)
    for resolution in "${resolutions[@]}";do
        sh /cluster/home/futing/Project/GBM/HiC/02data/04mcool/mcool2cool_single.sh $resolution $mcool_file
    done
done 

for resolution in ${resolutions[@]};do
    cooler merge ${cool_file}/${resolution}/G208_${resolution}.cool \
        ${cool_file}/${resolution}/G208R1_${resolution}.cool ${cool_file}/${resolution}/G208R2_${resolution}.cool
    cooler merge ${cool_file}/${resolution}/G213_${resolution}.cool \
        ${cool_file}/${resolution}/G213R1_${resolution}.cool ${cool_file}/${resolution}/G213R2_${resolution}.cool 
    cooler balance ${cool_file}/${resolution}/G208_${resolution}.cool
    cooler balance ${cool_file}/${resolution}/G213_${resolution}.cool

done
