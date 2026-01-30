#!/bin/bash

source activate ~/miniforge3/envs/RNA
export TMPDIR=/cluster2/home/futing/Project/panCancer/Analysis/ABC/H3K27ac/GEO/new/debug
cd /cluster2/home/futing/Project/panCancer/Analysis/ABC/H3K27ac/GEO/new

# while read -r name;do
for name in SRR15567106 SRR15567105;do
date
parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip
# done < <(sed -n '18,21p' srr0120.txt)
done
# done < "srr0120undump.txt"

# 这一部分是从硬盘传上来的 SRR
# while read -r name;do
# # for name in SRR24327300 SRR24327301;do
# date
# parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip
# done < <(sed -n '18,21p' srr0120.txt)