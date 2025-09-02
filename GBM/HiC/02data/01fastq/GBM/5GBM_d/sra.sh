#!/bin/bash
cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/5GBM_d
source activate RNA
name=$1

# prefetch -p -X 300GB --option-file srr.txt
# /cluster/home/futing/pipeline/Ascp/ascp.sh ./srr.txt ./ 20M
export TMPDIR=/cluster/home/futing/Project/GBM/WGS/tmp
# for name in $(cat srr.txt);do

echo -e "parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip"
parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip
# done
