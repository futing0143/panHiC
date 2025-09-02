#!/bin/bash

src_dir="/cluster/home/futing/Project/GBM/HiC/04mcool/mcool_from_otherGBM/"
dest_dir="/cluster/home/futing/Project/GBM/HiC/04mcool/"

for filepath in "$src_dir"/*; do
  filename=$(basename "$filepath")
  if [ -e "$dest_dir/$filename" ]; then
      # 如果目标目录中已存在文件，重命名新文件
    filename2=$(basename "$filename" ".mcool")
    echo "$dest_dir/$filename exists, rename $filename to ${filename2}.mcool"
    mv "$filepath" "$dest_dir/${filename2}.mcool"
  else
      # 如果不存在，直接移动
    mv "$filepath" "$dest_dir"
  
  fi
done
