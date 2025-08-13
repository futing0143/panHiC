#!/bin/bash

# 设置源文件夹路径
source_folder="/cluster/home/futing/Project/GBM/Corigami/Training_data/pHGG"

# 设置目标文件夹路径
target_folder="/cluster/home/futing/Project/GBM/Corigami/Training_data/pHGG"

# 设置txt文件路径
txt_file="/cluster/home/futing/Project/GBM/Corigami/Training_data/pHGG/pHGG_inf.txt"

# 创建大分组文件夹
while IFS=$'\t' read -r sample big_group small_group; do
    # 构建大分组文件夹路径
    big_group_folder="${target_folder}/${big_group}"
    
    # 检查大分组文件夹是否存在，不存在则创建
    if [ ! -d "$big_group_folder" ]; then
        mkdir -p "$big_group_folder"
    fi
    
    # 构建小分组文件夹路径
    small_group_folder="${big_group_folder}/${small_group}"
    
    # 检查小分组文件夹是否存在，不存在则创建
    if [ ! -d "$small_group_folder" ]; then
        mkdir -p "$small_group_folder"
    fi
    
    # 构建源文件路径
    source_file="${source_folder}/${sample}"
    
    # 移动文件到小分组文件夹
    mv "$source_file" "$small_group_folder/"
    
done < "$txt_file"
