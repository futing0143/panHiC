#!/bin/bash

source activate HiC


samtools view -h -@ 20 /cluster2/home/futing/Project/panCancer/CRC/GSE137188/13-1321/splits/SRR10093326.fastq.gz.bam \
	> /cluster2/home/futing/Project/panCancer/CRC/GSE137188/13-1321/splits/SRR10093326.fastq.gz.sam

nohup /cluster2/home/futing/Project/panCancer/scripts/juicerv2.sh -d /cluster2/home/futing/Project/panCancer/CRC/GSE137188 \
	-e MboI > /cluster2/home/futing/Project/panCancer/CRC/GSE137188/13-1321/debug/13-1321.log 2>&1 &

