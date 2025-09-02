#!/bin/bash
cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA
source activate /cluster/home/futing/anaconda3/envs/juicer
/cluster/home/futing/software/juicer_CPU/scripts/common/mega.sh \
    -g hg38 \
    -d /cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA \
    -D /cluster/home/futing/software/juicer_CPU \
    -y /cluster/home/futing/software/juicer_CPU/restriction_sites/hg38_Arima.txt \
    -s Arima


