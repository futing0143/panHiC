#!/bin/bash
cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U87_re2
ln -s /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U87/fastq ./fastq

/cluster/home/futing/software/juicer_new/scripts/juicer.sh \
    -D /cluster/home/futing/software/juicer_new \
    -d /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U87_re2 \
    -g hg38 \
    -p /cluster/home/futing/software/juicer_new/restriction_sites/hg38.genome \
    -z /cluster/home/futing/software/juicer_new/references/hg38.fa -s MboI
    