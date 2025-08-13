#!/bin/bash

# 定义当前目录路径
current_dir='/cluster/home/futing/Project/GBM/CTCF/GSE121601/G523'

# 使用 find 命令递归查找所有文件，并使用 xargs 和 sed 来重命名
find "$current_dir" -type f -exec bash -c '
    for file in "$@"; do
        # 检查文件名是否包含 _1 或 _2
        if [[ "$file" == *"_1"* ]] || [[ "$file" == *"_2"* ]]; then
            # 使用 sed 替换 _1 为 .R1 和 _2 为 .R2
            new_name=$(echo "$file" | sed -e "s/_1/.R1/" -e  "s/_2/.R2/")
            # 构造移动命令来重命名文件
            mv "$file" "$new_name" && echo "Renamed $file to $new_name"
        fi
        
    done
' bash {} +

for dir in "$current_dir"/*/; do
    # 获取子文件夹的名称
    folder_name=$(basename "$dir")
    if [[ "$folder_name" == SRR* ]]; then
    echo "Processing $folder_name"
    # 如果是文件，则执行shell脚本并传递子文件夹名称作为参数
    sh /cluster/home/futing/pipeline/fq2bigwig_v3.sh "$dir" "${folder_name}"
    #bamCoverage -b ${dir}/bam_files/${folder_name}_final.bam -o ${dir}/bigwig/${folder_name}_final.bw --normalizeUsing RPKM
    echo "BAM2BigWig completed!"
    fi
done