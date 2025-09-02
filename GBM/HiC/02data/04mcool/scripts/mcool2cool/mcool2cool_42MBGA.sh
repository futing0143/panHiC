#!/bin/bash
mcool_file=/cluster/home/futing/Project/GBM/HiC/02data/04mcool/01GBM/42MGBA.mcool

resolutions=(5000 10000 50000 100000 500000 1000000)
source activate ~/anaconda3/envs/hic

for resolution in "${resolutions[@]}";do
    sh /cluster/home/futing/Project/GBM/HiC/02data/04mcool/mcool2cool_single.sh $resolution $mcool_file
done
