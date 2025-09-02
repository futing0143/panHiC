#!/bin/bash
ls /cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA/EGAF00008040117/P455.SF1190.sorted.bam | while read line
#ls /cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA/bamHG38/sam/P455.SF11901/splits/P455.SF11901.sam | while read line
do 
	file_name=$(basename $line .sorted.bam)
	cd ./${file_name}
	mkdir -p ${file_name}/fastq ${file_name}/splits
	touch ${file_name}/fastq/${file_name}_R1.fastq.gz ${file_name}/fastq/${file_name}_R2.fastq.gz
	ln -s ./fastq/* ./splits/

	samtools view -h -o ${file_name}/splits/${file_name}.fastq.gz.sam -O SAM $line 


    /cluster/home/futing/software/juicer_CPU/scripts/juicer.sh \
	-S chimeric \
	-g hg38 \
	-d ./${file_name} \
	-s Arima \
	-p /cluster/home/futing/software/juicer_CPU/references/hg38.chrom.sizes \
	-y /cluster/home/tmp/EGA/hg38_Arima.txt \
	-z /cluster/home/futing/software/juicer_CPU/references/hg38_primary_assembly/bwa/hg38.fa \
	-D /cluster/home/futing/software/juicer_CPU/ > $file_name/juicer.log
done

