#!/bin/bash
cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U251_CPU_slurm
source activate /cluster/home/futing/anaconda3/envs/juicer
data=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U251

mkdir -p aligned
# 如果用CPU的merge_nodups.txt文件是可以运行的
ln -s $data/aligned/merged_sort.txt ./aligned/merged_sort.txt
ln -s $data/aligned/merged_nodups.txt ./aligned/merged_nodups.txt
ln -s $data/aligned/dups.txt ./aligned/dups.txt
ln -s $data/aligned/opt_dups.txt ./aligned/opt_dups.txt
ln -s $data/fastq ./fastq
ln -s $data/splits ./splits

/cluster/home/futing/software/juicer/scripts/juicer.sh \
-S final \
-D /cluster/home/futing/software/juicer/ \
-d . -g hg38 \
-p /cluster/home/futing/software/juicer/restriction_sites/hg38.genome \
-z /cluster/home/futing/software/juicer/references/hg38.fa -s DpnII