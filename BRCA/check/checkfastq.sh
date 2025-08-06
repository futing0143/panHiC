#!/bin/bash


# IFS=$','
# while read -r gse cell enzyme;do
# 	gunzip -t /cluster2/home/futing/Project/panCancer/CRC/GSE137188/${cell}/fastq/*
# done < "/cluster2/home/futing/Project/panCancer/CRC/meta/ctrl_meta.txt"


# find /cluster2/home/futing/Project/panCancer/CRC/GSE137188 -name '*_R2.fastq.gz' -exec basename {} _R2.fastq.gz \; | sort -u > donesrr.txt

find /cluster2/home/futing/Project/panCancer/CRC -name '*_R2.fastq.gz' | sort -u | while read -r file;do
	echo -e "Processing ${file%%_R2.fastq.gz}..."
	gunzip -t $file
	gunzip -t ${file%%_R2.fastq.gz}_R1.fastq.gz

done