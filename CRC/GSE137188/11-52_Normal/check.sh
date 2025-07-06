#!/bin/bash

cd /cluster2/home/futing/Project/panCancer/CRC/GSE137188/11-52_Normal
date
gunzip -t /cluster2/home/futing/Project/panCancer/CRC/GSE137188/11-52_Normal/fastq/*
# fastq1=./fastq/SRR10093297_R1.fastq.gz
# fastq2=./fastq/SRR10093297_R2.fastq.gz
# ligation="GATCGATC"

# num1=$(paste <(gunzip -c $fastq1) <(gunzip -c $fastq2) | awk '!((NR+2)%4)' | grep -cE $ligation)
# paste <(gunzip -c "$fastq1") <(gunzip -c "$fastq2") | head -n 8 | awk '!((NR+2)%4)' | grep -cE $ligation
# paste <(gunzip -c "$fastq1") <(gunzip -c "$fastq2") | head -n 8 | awk 'NR % 4 == 2' | grep -cE $ligation

# echo -e "$num1\t$num2" > count.txt