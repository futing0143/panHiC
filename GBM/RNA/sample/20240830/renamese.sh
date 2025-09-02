#!/bin/bash
# grx 的写法是保留R1部分，我全都改成了fastq.gz

IFS=$'\t'
while read -r cellline srr;do
	echo "Processing ${cellline} ${srr}..."
	fastq_dir=/cluster/home/futing/Project/GBM/RNA/sample/20240830/analysis/${cellline}/${srr}
	cd ${fastq_dir}
	# mv ${srr}.R1.fastq.gz ${srr}.fastq.gz
	mv trimmed/${srr}_trimmed.R1.fastq.gz trimmed/${srr}_trimmed.fastq.gz
done < '/cluster/home/futing/Project/GBM/RNA/sample/20240830/se.txt'
