#!/bin/bash

source activate ~/anaconda3/envs/juicer
cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U251_slurm
ln -s /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U251/fastq .

/cluster/home/futing/software/juicer/scripts/juicer.sh \
-D /cluster/home/futing/software/juicer/ \
-d /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U251_slurm -g hg38 \
-p /cluster/home/futing/software/juicer/restriction_sites/hg38.genome \
-z /cluster/home/futing/software/juicer/references/hg38.fa -s DpnII -t 30 -q gpu -l gpu