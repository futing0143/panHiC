#!/bin/bash
cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U251
cat U251p2.txt | while read i;do
    name=${i}
    prefetch -p -X 60GB ${name}
    source activate /cluster/home/futing/anaconda3/envs/download
    echo -e "parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip"
    parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip

done

rename _1 _R1 *fastq.gz
rename _2 _R2 *fastq.gz
rename .R1 _R1 *fastq.gz
rename .R2 _R2 *fastq.gz   
mv *.fastq.gz ./fastq

source activate /cluster/home/futing/anaconda3/envs/juicer
/cluster/home/futing/software/juicer_CPU/scripts/juicer.sh \
-D /cluster/home/futing/software/juicer_CPU/ \
-d /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U251 -g hg38 \
-p /cluster/home/futing/software/juicer_CPU/restriction_sites/hg38.genome \
-z /cluster/home/futing/software/juicer_CPU/references/hg38.fa -s DpnII -f