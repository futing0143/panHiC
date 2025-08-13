#!/bin/bash

cd /cluster/home/futing/Project/GBM/ChIP/GBM/TS667
#find . -name "*.fastq.gz" -exec mv {} . \;
#find . -name "SRR*" -type d -delete
cat $(sed 's/$/.R1.fastq.gz/' input.txt) > input.R1.fastq.gz
cat $(sed 's/$/.R2.fastq.gz/' input.txt) > input.R2.fastq.gz
cat $(sed 's/$/.R1.fastq.gz/' ip.txt) > ip.R1.fastq.gz
cat $(sed 's/$/.R2.fastq.gz/' ip.txt) > ip.R2.fastq.gz

/cluster/home/futing/pipeline/ChIP_CUTTAG/cut2rose_lite_v1.2.sh "" 30 input rose "" file.txt
