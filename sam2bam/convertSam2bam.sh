#!/bin/bash

# 定义包含SAM文件的根目录
root_directory=$1

# 检查samtools是否安装
if ! command -v samtools &> /dev/null
then
    echo "samtools could not be found, please install it first."
    exit 1
fi

# 使用find命令查找所有.sam文件，并执行samtools进行转换和删除操作
find "$root_directory" -type f -name "*.fastq.gz.sam" -print0 | while IFS= read -r -d '' file
do
    # 去除文件名末尾的回车符
    file="${file%$'\r'}"

    # 构建BAM文件的路径，将.sam替换为.bam
    bam_path="${file%.sam}.bam"
    
    # 使用samtools将SAM文件转换为BAM文件
    samtools view -@ 20 -bS "$file" > "$bam_path" && 
    # 如果转换成功，删除SAM文件
    rm "$file" && 
    echo "Converted and deleted: $file" && 
    # 输出转换后的BAM文件路径
    echo "Created BAM file: $bam_path"
done