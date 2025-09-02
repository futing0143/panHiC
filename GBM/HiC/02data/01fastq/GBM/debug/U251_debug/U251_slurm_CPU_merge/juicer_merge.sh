#!/bin/bash
source /cluster/home/futing/miniforge-pypy3/bin/activate /cluster/home/futing/miniforge-pypy3/envs/juicer
cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U251_debug/U251_slurm_merge
mkdir -p aligned
ln -s /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U251/fastq .
ln -s /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U251_debug/U251_slurm/splits .


/cluster/home/futing/software/juicer_CPU/scripts/juicer.sh \
-S merge \
-D /cluster/home/futing/software/juicer_CPU/ \
-d /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U251_debug/U251_slurm_merge -g hg38 \
-p /cluster/home/futing/software/juicer_CPU/restriction_sites/hg38.genome \
-z /cluster/home/futing/software/juicer_CPU/references/hg38.fa -s DpnII