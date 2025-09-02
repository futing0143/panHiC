#!/bin/bash


cd /cluster/home/futing/Project/GBM/RNA/sample/U251_trim
source activate RNA

sh /cluster/home/futing/pipeline/Ascp/ascp2.sh srr.txt . 20M

# #prefetch -p -X 60GB --option-file srr.txt

for name in $(cat srr.txt);do

    echo -e "parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip"
    parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip
done

/cluster/home/futing/pipeline/RNA/rna_pe_v2.sh /cluster/home/futing/Project/GBM/RNA/sample/U251_trim
