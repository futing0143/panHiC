#!/bin/bash
cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA_hg19/P455.SF11901_hg19

ls /cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA/EGAF00008040117/P455.SF11901.hic.bam | while read line
do
	file_name=$(basename $line .hic.bam)
	
	mkdir -p ./fastq ./splits
	touch ./fastq/${file_name}_R1.fastq.gz ./fastq/${file_name}_R2.fastq.gz
	ln -s ./fastq/* ./splits/

	
	sam=./splits/${file_name}.fastq.gz.sam
	samtools view -h -o $sam -O SAM $line
    site_file=/cluster/home/futing/software/juicer_CPU/restriction_sites/hg38_Arima.txt
    juiceDir=/cluster/home/futing/software/juicer_CPU
    stage=chimeric
    genomePath=/cluster/home/futing/software/juicer_CPU/restriction_sites/hg38.genome
    refSeq=/cluster/home/futing/software/juicer_CPU/references/hg38.fa

    /cluster/home/futing/software/juicer_CPU/scripts/juicer.sh \
        -S chimeric \
        -g hg38 \
        -d . \
        -p /cluster/home/futing/software/juicer_CPU/restriction_sites/hg38.genome \
        -y /cluster/home/futing/software/juicer_CPU/restriction_sites/hg38_Arima.txt \
        -z /cluster/home/futing/software/juicer_CPU/references/hg38.fa \
        -D /cluster/home/futing/software/juicer_CPU/ 
done