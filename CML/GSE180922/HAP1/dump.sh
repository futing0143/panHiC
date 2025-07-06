#!/bin/bash


cd /cluster2/home/futing/Project/panCancer/CML/GSE180922/HAP1
source activate RNA
# /cluster/home/futing/pipeline/Ascp/ascp2.sh ./HAP1.txt ./ 20M
# prefetch -p -X 60GB --option-file srr.txt
export TMPDIR='/cluster2/home/futing/Project/panCancer/CML/GSE180922/HAP1/HIC_tmp'
for name in $(cat HAP1.txt);do
    
    echo -e "parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip"
    parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip
done
