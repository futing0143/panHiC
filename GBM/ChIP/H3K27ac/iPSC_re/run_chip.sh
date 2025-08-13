#!/bin/bash
cd /cluster/home/futing/Project/GBM/ChIP/H3K27ac/iPSC_re
#cat SRR13720986.R1.fastq.gz SRR13720987.R1.fastq.gz > input.R1.fastq.gz
#cat SRR13720986.R2.fastq.gz SRR13720987.R2.fastq.gz > input.R2.fastq.gz

# sh /cluster/home/futing/pipeline/ChIP_CUTTAG/cut2rose_lite_v1.2.sh "" 30 input rose "" ./filename.txt 
sh /cluster/home/futing/pipeline/ChIP_CUTTAG/cut2rose_last_v1.2.sh "" 30 input rose "" ./filename.txt 

# 之前的代码有误 filename.txt 放进了两个SRR13720986 SRR13720987