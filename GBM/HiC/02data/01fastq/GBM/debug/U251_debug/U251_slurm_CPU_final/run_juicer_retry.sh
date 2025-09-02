#!/bin/bash
cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U251_slurm_CPU
source activate /cluster/home/futing/anaconda3/envs/juicer

mkdir -p aligned
ln -s ../U251_slurm/fastq ./fastq
ln -s ../U251_slurm/splits ./splits

awk '{if ($2 <= $6) print $0; else print $1,$6,$7,$8,$5,$2,$3,$4,$12,$13,$14,$9,$10,$11,$16,$15}' \
        /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U251_slurm/aligned/merged_sort.txt \
        > ./aligned/merged_sort.txt
sort --parallel=48 -S 32G -T ./tmp -m -k2,2d -k6,6d ./aligned/merged_sort.txt > ./aligned/merged_sort_sorted.txt && mv ./aligned/merged_sort_sorted.txt ./aligned/merged_sort.txt

/cluster/home/futing/software/juicer_CPU/scripts/juicer.sh \
-S dedup \
-D /cluster/home/futing/software/juicer_CPU/ \
-d /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U251_slurm_CPU -g hg38 \
-p /cluster/home/futing/software/juicer_CPU/restriction_sites/hg38.genome \
-z /cluster/home/futing/software/juicer_CPU/references/hg38.fa -s DpnII