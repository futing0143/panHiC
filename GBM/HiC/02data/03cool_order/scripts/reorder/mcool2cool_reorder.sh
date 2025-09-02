#!/bin/bash
source activate ~/anaconda3/envs/hic
mcool_dir=/cluster/home/futing/Project/GBM/HiC/02data/04mcool
resolution=$1
#resolutions=(5000 10000 25000 50000 100000 250000 500000 1000000 2500000)


cat ./${resolution}.txt | while read name;do
    mkdir -p /cluster/home/futing/Project/GBM/HiC/02data/03cool_order/${resolution}
    read -r -d '' mcool_file < <(find -L "${mcool_dir}" -type f -name "${name}.mcool" -print0)
    /cluster/home/futing/Project/GBM/HiC/02data/05file_transform/mcool2cool_single.sh \
        ${resolution} ${mcool_file} /cluster/home/futing/Project/GBM/HiC/02data/03cool_order
done


folderA=/cluster/home/futing/Project/GBM/HiC/02data/03cool_order/${resolution}
folderB=/cluster/home/futing/Project/GBM/HiC/02data/03cool/${resolution}

# 遍历文件夹B中的所有文件
for fileB in "$folderB"/*.cool; do
    # 获取文件名（不包括路径）
    filename=$(basename "$fileB")

    # 检查文件夹A中是否存在该文件
    if [ ! -e "$folderA/$filename" ]; then
        # 如果文件夹A中不存在该文件，则复制文件B到文件夹A
        cp "$fileB" "$folderA"
        echo "Copied $filename to $folderA"
    fi
done