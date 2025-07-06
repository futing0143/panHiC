#!/bin/bash

# /cluster/home/futing/pipeline/Ascp/ascp.sh ./GC.txt ./ 20M
cd /cluster2/home/futing/Project/panCancer/CML/GSE182500/HAP1
source activate RNA
/cluster/home/futing/pipeline/Ascp/ascp.sh ./srr.txt ./ 20M

# prefetch -p -X 60GB --option-file srr.txt
# for name in $(cat srr.txt);do
    
#     echo -e "parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip"
#     parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip
# done
