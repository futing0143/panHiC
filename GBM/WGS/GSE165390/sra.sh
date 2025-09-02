#!/bin/bash
source activate /cluster/home/futing/anaconda3/envs/download
find /cluster/home/futing/Project/GBM/WGS/GSE165390 -name '*.sra' -type f | while read name; do
    echo -e "parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip"
    parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip
done