#!/bin/bash

cd /cluster2/home/futing/Project/panCancer/CRC
source activate HiC
for i in 16-178;do
	rm -r /cluster2/home/futing/Project/panCancer/CRC/GSE137188/${i}/aligned
	file=$(find ./GSE137188/${i}/splits/ -name '*fastq.gz.bam')
	samfile="${file%.bam}.sam"

	samtools view -@ 20 -h $file > ${samfile} # 使用4个线程
	sh /cluster2/home/futing/Project/panCancer/CRC/sbatch.sh GSE137188 ${i} MboI
done


# 14-328 14-426