#!/bin/bash
source activate ~/anaconda3/envs/hic
folder=/cluster/home/futing/Project/GBM/HiC/02data/03cool
cd /cluster/home/futing/Project/GBM/HiC/02data/04mcool/01GBM
g208_files=$(find "$folder" -type f -name "G208_*.cool")
# 查找包含 G213 的所有 .cool 文件
g213_files=$(find "$folder" -type f -name "G213_*.cool")

echo "Merging ${g208_files}..."
#cooler zoomify -o /cluster/home/futing/Project/GBM/HiC/02data/04mcool/01GBM/GSE229962_RAW/G213.mcool $g208_files
hicConvertFormat -m $g208_files --inputFormat cool --outputFormat mcool -o G208.mcool
# 将找到的 G213 .cool 文件合并为 G213.mcool
echo "Merging G213 .cool files into $output_G213..."
#cooler zoomify -o /cluster/home/futing/Project/GBM/HiC/02data/04mcool/01GBM/GSE229962_RAW/G213.mcool $g213_files
hicConvertFormat -m $g213_files --inputFormat cool --outputFormat mcool -o G213.mcool