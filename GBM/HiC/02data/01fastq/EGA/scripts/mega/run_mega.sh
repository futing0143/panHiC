#!/bin/bash
cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA
source activate /cluster/home/futing/anaconda3/envs/juicer
/cluster/home/futing/software/juicer_CPU/scripts/common/mega.sh \
    -g hg38 \
    -d /cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA_re \
    -D /cluster/home/futing/software/juicer_CPU \
    -s Arima


