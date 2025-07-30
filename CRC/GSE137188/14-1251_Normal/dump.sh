#!/bin/bash

source activate RNA

cd /cluster2/home/futing/Project/panCancer/CRC/GSE137188/14-1251_Normal
debugdir=/cluster2/home/futing/Project/panCancer/CRC/GSE137188/14-1251_Normal
name=SRR10093267

export TMPDIR=${debugdir}/debug
echo -e "parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip"
parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip

mv ${name}_1.fastq.gz ./fastq/${name}_R1.fastq.gz
mv ${name}_2.fastq.gz ./fastq/${name}_R2.fastq.gz
ln -s ./fastq/${name}_R2.fastq.gz ./splits/${name}_R2.fastq.gz
ln -s ./fastq/${name}_R1.fastq.gz ./splits/${name}_R1.fastq.gz


sh /cluster2/home/futing/Project/panCancer/CRC/sbatch.sh GSE137188 14-1251_Normal MboI
