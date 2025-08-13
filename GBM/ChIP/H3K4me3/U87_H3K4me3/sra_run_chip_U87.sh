#!/bin/bash

cd /cluster/home/futing/Project/GBM/ChIP/GBM/U87_prefetch
prefetch -p -X 60GB --option-file srr.txt
for name in $(cat srr.txt);do
    source activate /cluster/home/futing/anaconda3/envs/download
    echo -e "parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip"
    parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip
done

/cluster/home/futing/pipeline/ChIP_CUTTAG/cut2rose_lite_single.sh "" 30 SRR14862252 rose ""

