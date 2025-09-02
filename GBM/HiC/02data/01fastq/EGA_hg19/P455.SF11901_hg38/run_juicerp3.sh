#!/bin/bash
dir=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA_hg19/P455.SF11901_hg38
source activate juicer
cd $dir
ln -s $dir/liftOver/merged_nodups_hg38.bed $dir/aligned/merged_nodups.txt 

awk '{if ($2 <= $6) print $0; else print $1,$6,$7,$8,$5,$2,$3,$4,$12,$13,$14,$9,$10,$11,$16,$15}' ./liftOver/merged_nodups_hg38.bed > aligned/merged_nodups_correct.txt
sort -k2,2d -k6,6d aligned/merged_nodups_correct.txt > aligned/merged_nodups.txt


/cluster/home/futing/software/juicer_CPU/scripts/juicer.sh \
	-S final \
	-g hg38 \
	-d /cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA_hg19/P455.SF11901_hg38 \
	-p /cluster/home/futing/software/juicer_CPU/restriction_sites/hg38.genome \
	-y /cluster/home/futing/software/juicer_CPU/restriction_sites/hg38_Arima.txt \
	-z /cluster/home/futing/software/juicer_CPU/references/hg38.fa \
	-D /cluster/home/futing/software/juicer_CPU/ 