#!/bin/bash


cd /cluster2/home/futing/Project/panCancer/MB
# find . -name '*_2.fastq.gz' -exec basename {} _2.fastq.gz \; | while read srr;do
# 	gunzip -t ${srr}/*.fastq.gz
# done
source activate HiC
date
ls *.gz.1 | while read i;do
	name=$(basename $i .1)
	echo -e "Processing ${name}..."
	mv ${i} ${name}
	gunzip -t ${name}
done

# gunzip -t /cluster2/home/futing/Project/panCancer/MB/SRR25592948_*.fastq.gz
