#!/bin/bash



cd /cluster2/home/futing/Project/panCancer/CRC/GSE137188/14-426
mkdir splits

for i in SRR10093337 SRR10093338;do

	samtools view -h -@ 20 -o ./splits/${i}.fastq.gz.sam ../14-426_old/splits/${i}.fastq.gz.bam
done


sh /cluster2/home/futing/Project/panCancer/CRC/sbatch.sh GSE137188 14-426 MboI "-S chimeric"