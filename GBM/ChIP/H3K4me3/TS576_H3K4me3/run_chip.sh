#!/bin/bash

cd /cluster/home/futing/Project/GBM/ChIP/GBM/TS576_H3K4me3
#find ./sra -name "*.fastq.gz" -exec mv {} . \;
#cat SRR24142116_1.fastq.gz SRR24142115_1.fastq.gz > input.R1.fastq.gz
#cat SRR24142116_2.fastq.gz SRR24142115_2.fastq.gz > input.R2.fastq.gz

/cluster/home/futing/pipeline/ChIP_CUTTAG/cut2rose_lite_v1.2.sh "" 30 input rose "" ./input.txt