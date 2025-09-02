#!/bin/bash


filelist=$1
cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA
source /cluster/home/futing/miniforge-pypy3/etc/profile.d/conda.sh
conda activate juicer
cat ${filelist} | while read name;do
    echo -e "\nProcessing $name...\n"
    cd $name
    mkdir ./{aligned,fastq}
    touch ./fastq/${name}_R1.fastq.gz ./fastq/${name}_R2.fastq.gz
    sort -k2,2d -k6,6d ./liftOver/merged_sort_correct.txt > aligned/merged_sort.txt

    # process juicer
    /cluster/home/futing/software/juicer_CPU/scripts/juicer.sh \
    -S dedup \
    -g hg38 \
    -d /cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA/$name \
    -s Arima \
    -p /cluster/home/futing/software/juicer_CPU/restriction_sites/hg38.genome \
    -z /cluster/home/futing/software/juicer_CPU/references/hg38.fa \
    -D /cluster/home/futing/software/juicer_CPU/ > juicer.log 2>&1


    cd ..
done