#!/bin/bash
cd /cluster/home/futing/Project/GBM/ChIP/GBM/TS576_H3K4me3/sra
data_dir=/cluster/home/futing/Project/GBM/ChIP/GBM/TS576_H3K4me3/sra

cat ./H3K4me3.txt | while read name;do
    mkdir -p ./${name}
    prefetch -p -X 60GB ${name}
    source activate /cluster/home/futing/anaconda3/envs/download
    echo -e "parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ${data_dir}/${name} --split-3 --gzip"
    parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ${data_dir}/${name} --split-3 --gzip
    
done
