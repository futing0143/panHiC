#!/bin/bash

# cd /cluster/home/futing/Project/GBM/HiC/10loop/mustache/10000
# for name in ipsc NPC;do
#     file=/cluster/home/futing/Project/GBM/HiC/02data/03cool_order/10000/${name}_10000.cool
#     mustache -f $file -pt 0.05 -st 0.8 -r 10kb -norm weight -o ${name}_10k_mustache.tsv
#     sed '1d' ${name}_10k_mustache.tsv > ${name}_10k_mustache.bedpe
#     rm ${name}_10k_mustache.tsv
# done
source /cluster/home/futing/miniforge-pypy3/etc/profile.d/conda.sh
conda activate hic

cd /cluster/home/futing/Project/GBM/HiC/10loop/mustache/10000
file=/cluster/home/futing/Project/GBM/HiC/02data/03cool_order/10000/GBM_10000.cool
mustache -f $file -pt 0.05 -st 0.8 -r 10kb -norm weight -o GBM_10k_mustache.tsv
sed '1d' GBM_10k_mustache.tsv > GBM_10k_mustache.bedpe
rm GBM_10k_mustache.tsv

cd /cluster/home/futing/Project/GBM/HiC/10loop/mustache/5000
file=/cluster/home/futing/Project/GBM/HiC/02data/03cool_order/5000/GBM_5000.cool
mustache -f $file -pt 0.05 -st 0.8 -r 5kb -norm weight -o GBM_5k_mustache.tsv
sed '1d' GBM_5k_mustache.tsv > GBM_5k_mustache.bedpe
rm GBM_5k_mustache.tsv
