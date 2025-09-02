#!/bin/bash

source activate juicer
bwa mem -SP5M -t 104 /cluster/home/futing/software/juicer_CPU/references/hg38.fa \
    /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/42MGBA/fastq/sra/SRR25569739_1.fastq.gz \
    /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/42MGBA/fastq/sra/SRR25569739_2.fastq.gz \
    > /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/42MGBA/fastq/sra/SRR25569739.fastq.gz.sam
