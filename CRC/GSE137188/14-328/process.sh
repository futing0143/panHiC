#!/bin/bash



cd /cluster2/home/futing/Project/panCancer/CRC/GSE137188/14-328
ln -s /cluster2/home/futing/Project/panCancer/CRC/GSE137188/14-328_old/fastq ./
mkdir splits

for i in SRR10093281 SRR10093282;do

	samtools view -h -@ 20 -o ./splits/${i}.fastq.gz.sam ../14-328_old/splits/${i}.fastq.gz.bam
done


sh /cluster2/home/futing/Project/panCancer/CRC/sbatch.sh GSE137188 14-328 MboI
