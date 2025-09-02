#!/bin/bash

cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA_re
result=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA_re
data=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA
source activate /cluster/home/futing/anaconda3/envs/juicer


cat namep1.txt | while read line
do
    echo -e '\n'Processing $line...'\n'
    name=$(basename $line .hic.bam)
    mkdir -p $result/$name
    cd $result/$name

    mkdir -p $result/$name/aligned
    ln -s $data/$name/fastq .
    ln -s $data/$name/splits .
    ln -s $data/$name/aligned/merged_sort.txt ./aligned/merged_sort.txt
    ln -s $data/$name/aligned/merged_nodups.txt ./aligned/merged_nodups.txt
    ln -s $data/$name/aligned/opt_dups.txt ./aligned/opt_dups.txt
    ln -s $data/$name/aligned/dups.txt ./aligned/dups.txt
    /cluster/home/futing/software/juicer_CPU/scripts/juicer.sh \
        -S final \
        -g hg38 \
        -d $result/$name \
        -s Arima \
        -p /cluster/home/futing/software/juicer_CPU/restriction_sites/hg38.genome \
        -y /cluster/home/futing/software/juicer_CPU/restriction_sites/hg38_Arima.txt \
        -z /cluster/home/futing/software/juicer_CPU/references/hg38.fa \
        -D /cluster/home/futing/software/juicer_CPU/ > juicer.log 2>&1
done