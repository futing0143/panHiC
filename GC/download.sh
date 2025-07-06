#!/bin/bash

# /cluster/home/futing/pipeline/Ascp/ascp.sh ./GC.txt ./ 20M
/cluster/home/futing/pipeline/Ascp/ascp.sh ./GCundone.txt ./ 20M

# prefetch ./GC.txt 
# prefetch -p -X 60GB --option-file GC.txt
# for name in $(cat srr.txt);do
#     source activate RNAseq
#     echo -e "parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip"
#     parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip
# done