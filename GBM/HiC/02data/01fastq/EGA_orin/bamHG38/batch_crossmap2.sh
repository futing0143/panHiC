#!/bin/bash

# 确保chain文件的路径是正确的
CHAIN_FILE_PATH="/cluster/home/jialu/biosoft/hg19ToHg38.over.chain.gz"

# 逐行读取文件列表
while IFS= read -r file; do
    # # 从列表中读取每个文件的路径
    # if [[ -f "$file" ]]; then
    #     # 从文件名中提取基本名称（去掉路径和.hic.bam扩展名）
    #     base_name=$(basename "$file" .hic.bam)
        
    #     # 构建输出文件名
    #     output_file="${base_name}_hg38.hic.bam"
        
    #     # 执行CrossMap转换命令
    #     CrossMap.py bam "$CHAIN_FILE_PATH" "$file" "$output_file"
        
    #     # 检查命令是否执行成功
    #     if [ $? -eq 0 ]; then
    #         echo "Conversion of $file to $output_file completed successfully."
    #     else
    #         echo "Error occurred during the conversion of $file."
    #     fi
    # else
    #     echo "File $file does not exist or is not a regular file."
    # fi
    output="${file%.bam.bam}.sam"
    # 使用samtools view命令将BAM转换为SAM
    samtools view  $file > $output
done < hic_bam_files_list2.txt
