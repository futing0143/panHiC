#!/bin/bash
source activate RNA

export TMPDIR=/cluster/home/futing/Project/GBM/WGS/tmp
find /cluster/home/futing/Project/GBM/WGS/PRJNA541986 -name 'SRR*' -type f | while read name; do
    echo -e "parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip"
    parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip
done