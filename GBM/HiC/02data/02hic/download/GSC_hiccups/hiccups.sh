#!/bin/bash
source activate ~/anaconda3/envs/juicer

for i in G523 G567 G583;do
    mkdir -p /cluster/home/futing/Project/GBM/HiC/02data/02hic/GSC3/${i}
    cd /cluster/home/futing/Project/GBM/HiC/02data/02hic/GSC3/${i}
    #mv ../${i}_inter_30.hic .

    sh /cluster/home/futing/software/juicer_CPU/scripts/common/juicer_hiccups.sh \
        -j /cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar \
        -g hg38 -i ${i}_inter_30.hic
done