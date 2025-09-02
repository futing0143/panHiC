#!/bin/bash

cd /cluster/home/futing/Project/GBM/RNA/U343
source /cluster/home/futing/miniforge-pypy3/etc/profile.d/conda.sh
conda activate scRNA

# #prefetch -p -X 60GB --option-file srr.txt
# sh /cluster/home/futing/pipeline/Ascp/ascp2.sh srr.txt . 20M
# for name in $(cat srr.txt);do

#     echo -e "parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip"
#     parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip
# done



/cluster/home/futing/pipeline/RNA/rna_se.sh /cluster/home/futing/Project/GBM/RNA/U343