#!/bin/bash

dir=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA_hg19/P455.SF11901_hg38

# 合并 read1_read2 merged_nohups_hg19
sed 's/\t/ /g' $dir/liftOver/read1_read2_hg38.bed > $dir/liftOver/read1_read2_tmp.bed \
	&& mv $dir/liftOver/read1_read2_tmp.bed $dir/liftOver/read1_read2_hg38.bed

sort -k17,17 $dir/liftOver/merged_nodups_hg19NR.bed > $dir/liftOver/merged_nodups_hg19_sorted.bed
join -1 5 -2 17 -o 2.1,1.1,1.2,2.4,2.5,1.3,1.4,2.8,2.9,2.10,2.11,2.12,2.13,2.14,2.15,2.16 \
    $dir/liftOver/read1_read2_hg38.bed \
    $dir/liftOver/merged_nodups_hg19_sorted.bed > $dir/liftOver/merged_nodups_hg38.bed
ln -s $dir/liftOver/merged_nodups_hg38.bed $dir/aligned/merged_nodups.txt 
# join 后检查 1_10 10_1的问题 这个脚本有问题
#cp /cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA_hg19/P455.SF11901/aligned/header ./aligned/

# 04准备 juicer
ln -s /cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA_hg19/P455.SF11901/fastq .
ln -s /cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA_hg19/P455.SF11901/splits .

source activate juicer
/cluster/home/futing/software/juicer_CPU/scripts/juicer.sh \
	-S final \
	-g hg38 \
	-d /cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA_hg19/P455.SF11901_hg38 \
	-p /cluster/home/futing/software/juicer_CPU/restriction_sites/hg38.genome \
	-y /cluster/home/futing/software/juicer_CPU/restriction_sites/hg38_Arima.txt \
	-z /cluster/home/futing/software/juicer_CPU/references/hg38.fa \
	-D /cluster/home/futing/software/juicer_CPU/ 