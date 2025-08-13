#!/bin/bash

cd /cluster/home/futing/Project/GBM/ChIP/GBM/TS667_prefetch
#prefetch -p -X 60GB --option-file srr.txt
#for name in $(cat srr.txt);do
#    source activate /cluster/home/futing/anaconda3/envs/download
#    echo -e "parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip"
#    parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip
#done

cat $(sed 's/$/.R1.fastq.gz/' input.txt) > input.R1.fastq.gz
cat $(sed 's/$/.R2.fastq.gz/' input.txt) > input.R2.fastq.gz
cat $(sed 's/$/.R1.fastq.gz/' ip.txt) > ip.R1.fastq.gz
cat $(sed 's/$/.R2.fastq.gz/' ip.txt) > ip.R2.fastq.gz

/cluster/home/futing/pipeline/ChIP_CUTTAG/cut2rose_lite_v1.2.sh "" 30 input rose "" file.txt