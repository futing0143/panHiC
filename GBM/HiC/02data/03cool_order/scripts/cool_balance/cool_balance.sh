#!/bin/bash

# 重新 balance 无法 balance 的文件
conda activate hic
cd /cluster/home/futing/Project/GBM/HiC/02data/03cool_order
:<<'END'
while IFS=$' ' read -r name reso;do
    cooler balance --max-iters 400 -f ./${reso}/${name}_${reso}.cool
done < "./balance.txt"


cooler balance --max-iters 400 -f ./50000/G567_50000.cool
END



#02 NHA重新balance

resolutions=(5000 10000 25000 50000 100000 250000 500000 1000000 2500000)
for reso in ${resolutions[@]};do
    cooler balance --max-iters 1000 -f ./${reso}/NHA_${reso}.cool
    cooler balance --max-iters 1000 -f /cluster/home/futing/Project/GBM/HiC/02data/04mcool/Control/NHA.mcool::/resolutions/${reso}
done