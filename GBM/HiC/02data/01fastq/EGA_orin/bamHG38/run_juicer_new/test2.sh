#!/bin/bash

# 定义文件列表的路径
filelist=file2

# 遍历文件列表中的每个路径
while IFS= read -r bamfile; do
  # 去除可能存在的换行符
  bamfile=$(echo "$bamfile" | tr -d '\n')

  # 检查文件是否存在
  if [ ! -f "$bamfile" ]; then
    echo "Warning: File does not exist, skipping: $bamfile"
    continue
  fi

  # 获取文件所在的目录
  dir=$(dirname "$bamfile")

  # 进入该目录
  cd "$dir" || exit

  # 对 BAM 文件进行排序
  echo "Sorting $bamfile..."
  samtools sort "$bamfile" -o "${bamfile%.bam}.sorted.bam"
  
  # 检查排序命令是否成功执行
  if [ $? -ne 0 ]; then
    echo "Error: Sorting failed for $bamfile"
    cd - > /dev/null
    continue
  fi

  # 对排序后的 BAM 文件建立索引
  echo "Indexing ${bamfile%.bam}.sorted.bam..."
  samtools index "${bamfile%.bam}.sorted.bam"
  
  # 检查索引命令是否成功执行
  if [ $? -ne 0 ]; then
    echo "Error: Indexing failed for ${bamfile%.bam}.sorted.bam"
  fi

  # 返回上一级目录
  cd - > /dev/null

done < "$filelist"

echo "Processing complete."
