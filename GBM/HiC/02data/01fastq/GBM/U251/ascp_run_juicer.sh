#!/bin/bash

#/cluster/home/futing/pipeline/Ascp/ascp.sh ./U251.txt /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U251  30M

cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U251
mkdir -p fastq
for i in SRR8446743 SRR8446744 SRR8446745 SRR8446746;do
    mv ./$i/*.fastq.gz ./fastq/
done
cd ./fastq
rename _1 _R1 *fastq.gz
rename _2 _R2 *fastq.gz
cd ..
source activate /cluster/home/futing/anaconda3/envs/juicer
/cluster/home/futing/software/juicer_CPU/scripts/juicer.sh \
-D /cluster/home/futing/software/juicer_CPU/ \
-d /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U251 -g hg38 \
-p /cluster/home/futing/software/juicer_CPU/restriction_sites/hg38.genome \
-z /cluster/home/futing/software/juicer_CPU/references/hg38.fa -s DpnII 