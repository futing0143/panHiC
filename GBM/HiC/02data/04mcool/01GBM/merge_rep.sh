#!/bin/bash
cd /cluster/home/futing/Project/GBM/HiC/02data/04mcool/01GBM/GSE229962_RAW

for file in /cluster/home/futing/Project/GBM/HiC/02data/04mcool/01GBM/GSE229962_RAW/*-Arima-allReps-filtered.mcool; do
  # 提取 GSM 后面的部分（即 xx）
  new_name=$(echo $file | sed 's/.*GSM[0-9]\+_\([a-zA-Z0-9]\+\)-Arima-allReps-filtered.mcool/\1.mcool/')
  mv "$file" "/cluster/home/futing/Project/GBM/HiC/02data/04mcool/01GBM/GSE229962_RAW/$new_name"
done

cooler merge G208.mcool G208R1.mcool G208R2.mcool 
cooler merge G213.mcool G213R1.mcool G213R2.mcool