#!/bin/bash

# 进入包含目标文件夹的目录
cd /cluster/home/Kangwen/lft/data/HIRES
source_path='/cluster/home/Kangwen/Hic/data_new/HIRES/GSE223917'
pattern='HIRES_'
# 查找所有符合特定模式（dipC_SRRxxxx_tmp）的文件夹
for folder in $source_path/${pattern}SRR*_tmp; do
    # 去除前缀和后缀
    stripped_name=${folder#*${pattern}}
    stripped_name=${stripped_name%_tmp}

    # 定义目标文件路径
    target_file="$folder/Result/${stripped_name}.mcool"

    # 检查目标文件是否存在
    if [ -e "${target_file}" ]; then
        # 创建指向目标文件的软链接
        ln -s "$target_file" ${stripped_name}.mcool
        echo "mkdir soft link ${stripped_name}"
    fi
done

# 查找所有符合特定模式（dipC_SRRxxxx_tmp）的文件夹
#for folder in /cluster/home/Kangwen/Hic/data_new/dipC/GSE117874/dipC_SRR*_tmp; do
#    # 去除前缀和后缀
#    stripped_name=${folder#dipC_}
#    stripped_name=${stripped_name%_tmp}
#    echo "mkdir soft link ${stripped_name}"
#done