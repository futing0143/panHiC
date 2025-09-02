#!/bin/bash
cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U251_slurm_CPU_2
source activate /cluster/home/futing/anaconda3/envs/juicer

mkdir -p aligned
ln -s ../U251_slurm/fastq ./fastq
ln -s ../U251_slurm/splits ./splits

ln -s /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U251_slurm/aligned/merged_sort.txt ./aligned/merged_sort.txt



/cluster/home/futing/software/juicer_CPU/scripts/juicer.sh \
-S dedup \
-D /cluster/home/futing/software/juicer_CPU/ \
-d /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U251_slurm_CPU_2 -g hg38 \
-p /cluster/home/futing/software/juicer_CPU/restriction_sites/hg38.genome \
-z /cluster/home/futing/software/juicer_CPU/references/hg38.fa -s DpnII