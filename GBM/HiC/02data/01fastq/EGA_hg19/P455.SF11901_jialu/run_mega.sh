#!/bin/bash

# 取前16列

awk -F '\t' '{for (i=1; i<=16; i++) printf "%s ", $i; print " "}' \
    /cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA_hg19/P455.SF11901/mega/aligned/merged_nodups1.txt \
    > /cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA_hg19/P455.SF11901_test/aligned/merged_nodups.txt

/cluster/home/futing/software/juicer_CPU/scripts/common/mega.sh \
    -g hg38 \
    -d /cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA_hg19/P455.SF11901_test \
    -D /cluster/home/futing/software/juicer_CPU \
    -p /cluster/home/futing/software/juicer_CPU/restriction_sites/hg38.genome \
    -z /cluster/home/futing/software/juicer_CPU/references/hg38.fa \
    -s /cluster/home/tmp/EGA/hg38_Arima.txt

