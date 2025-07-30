#!/bin/bash

cd /cluster2/home/futing/Project/panCancer/CRC/GSE137188/16-178/splits
for i in SRR10093271 SRR10093272;do

	samtools view -h -@ 20 ${i}.fastq.gz.bam > ${i}.fastq.gz.sam
done