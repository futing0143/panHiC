#!/bin/bash

root_dir=/cluster/home/futing/Project/GBM/HiC/10loop
# 查找所有名为 "NPC_new" 的文件夹并重命名为 "NPCnew"
find "$root_dir" -name '*NPC_new*' | while read item; do
    # 获取包含 NPC_new 的路径
    new_item=$(echo "$item" | sed 's/NPC_new/NPCnew/g')  # 替换 NPC_new 为 NPCnew

    # 重命名文件或文件夹
    mv "$item" "$new_item"
    echo "Renamed: $item -> $new_item"
done

find "$root_dir" -name '*iPSC_new*' | while read item; do
    # 获取包含 NPC_new 的路径
    new_item=$(echo "$item" | sed 's/iPSC_new/iPSCnew/g')  # 替换 NPC_new 为 NPCnew

    # 重命名文件或文件夹
    mv "$item" "$new_item"
    echo "Renamed: $item -> $new_item"
done