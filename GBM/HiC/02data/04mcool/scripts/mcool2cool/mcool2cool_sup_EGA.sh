#!/bin/bash

resolutions=(25000 250000 2500000)
top_folder=/cluster/home/futing/Project/GBM/HiC/02data/04mcool/01GBM/EGA_re
source activate ~/anaconda3/envs/hic
cat name3.txt | while read prefix
do
    # 使用find命令递归搜索匹配的文件
    read -r -d '' mcool_file < <(find "$top_folder" -type f -name "$prefix.mcool" -print0)
    echo -e "\nProcessing ${mcool_file}...\n"
    for resolution in "${resolutions[@]}";do
        sh /cluster/home/futing/Project/GBM/HiC/02data/04mcool/mcool2cool_single.sh $resolution $mcool_file
    done

done 

