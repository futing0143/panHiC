#!/bin/bash

wgs=/cluster/home/futing/ref_genome/hg38_gencode/GATK/wgs_fastq_to_gvcf_20180509.sh
name=$1
cd /cluster/home/futing/Project/GBM/WGS/GSE202644
rename _1 .R1 *_1.fastq.gz
rename _2 .R2 *_2.fastq.gz

# for i in *.R1.fastq.gz; do
	# name=$(basename $i .R1.fastq.gz)
echo -e "Processing $name...\n"

$wgs \
	${name}.R1.fastq.gz \
	${name}.R2.fastq.gz \
	"01" \
	"lib1" \
	${name} \
	/cluster/home/futing/Project/GBM/WGS/GSE202644
# done


