#!/bin/bash

source activate ~/miniforge3/envs/RNA
export TMPDIR=/cluster2/home/futing/Project/panCancer/Analysis/ABC/ATAC/GEO/new/debug
cd /cluster2/home/futing/Project/panCancer/Analysis/ABC/ATAC/GEO/new

while read -r name;do
# for name in SRR24327300 SRR24327301;do
date
parallel-fastq-dump --sra-id /cluster2/home/futing/Project/panCancer/Analysis/ABC/ATAC/GEO/new/${name} --threads 40 --outdir ./ --split-3 --gzip
# done < <(sed -n '18,21p' srr0120.txt)
done < "dumperr0121.txt"

# 这一部分是从硬盘传上来的 SRR
# while read -r name;do
# # for name in SRR24327300 SRR24327301;do
# date
# parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip
# done < <(sed -n '18,21p' srr0120.txt)