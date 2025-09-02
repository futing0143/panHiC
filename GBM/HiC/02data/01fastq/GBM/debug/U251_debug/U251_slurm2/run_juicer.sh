#!/bin/bash

cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U251_slurm2
source activate /cluster/home/futing/anaconda3/envs/juicer

ln -s /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U251/fastq fastq


/cluster/home/futing/software/SLURM/scripts/juicer.sh \
    -D /cluster/home/futing/software/SLURM \
    -d /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U251_slurm2 -g hg38 \
    -p /cluster/home/futing/software/SLURM/restriction_sites/hg38.genome \
    -z /cluster/home/futing/software/SLURM/references/hg38.fa -s DpnII -t 30 -q gpu -l gpu