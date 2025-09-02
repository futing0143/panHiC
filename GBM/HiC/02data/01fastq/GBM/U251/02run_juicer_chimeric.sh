#!/bin/bash

source activate /cluster/home/futing/anaconda3/envs/juicer
cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U251_CPU/
find /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U251/splits -name "*.fastq.gz.sam" | while read line;do
    name=$(basename $line .fastq.gz.sam)
    mkdir -p ./splits/ ./fastq/
    echo "Processing $line..."
    ln -s $line /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U251_CPU/splits/${name}.fastq.sam
    touch ./fastq/${name}_R1.fastq ./fastq/${name}_R2.fastq
    cd ./splits
    ln -s ../fastq/* .
    cd ..
done

/cluster/home/futing/software/juicer_CPU/scripts/juicer.sh \
-S chimeric \
-D /cluster/home/futing/software/juicer_CPU/ \
-d /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U251_CPU -g hg38 \
-p /cluster/home/futing/software/juicer_CPU/restriction_sites/hg38.genome \
-z /cluster/home/futing/software/juicer_CPU/references/hg38.fa -s DpnII 