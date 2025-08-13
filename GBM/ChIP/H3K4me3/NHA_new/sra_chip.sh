#!/bin/bash

cd /cluster/home/futing/Project/GBM/ChIP/H3K4me3/NHA_new
source /cluster/home/futing/miniforge-pypy3/etc/profile.d/conda.sh
conda activate scRNA

# prefetch -p -X 60GB --option-file srr.txt
sh /cluster/home/futing/pipeline/Ascp/ascp2.sh srr.txt . 10M
for name in $(cat srr.txt);do

    echo -e "parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip"
    parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip
done

sh /cluster/home/futing/pipeline/ChIP_CUTTAG/cut2rose_lite_v1.sh "" 30 SRR22197596 rose ""
