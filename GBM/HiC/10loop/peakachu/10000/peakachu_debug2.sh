#!/bin/bash

# 这是因为00peakachu.sh用的是KR的数据，这里使用order的数据  

source /cluster/home/futing/miniforge-pypy3/etc/profile.d/conda.sh
conda activate peakachu
cd /cluster/home/futing/Project/GBM/HiC/10loop/peakachu/10000
mkdir results_new
cd /cluster/home/futing/Project/GBM/HiC/10loop/peakachu/10000/results_new


###4.0 run peakachu
cat debug_depth.txt  | while read i
do
    echo "Processing ${i}..."
    name=$(echo ${i} | awk '{print $1}')
    depth=$(echo ${i} | awk '{print $2}')
    peakachu score_genome -r 10000 --clr-weight-name weight -p /cluster/home/tmp/GBM/HiC/02data/03cool_order/10000/${name}_10000.cool \
        -O ${name}-peakachu-10kb-scores.bedpe \
        -m /cluster/home/futing/Project/GBM/HiC/10loop/peakachu/peakachu/high-confidence.${depth}.10kb.w6.pkl
    peakachu pool -r 10000 -i ${name}-peakachu-10kb-scores.bedpe -o ${name}-peakachu-10kb-loops.0.95.bedpe -t 0.95
done


