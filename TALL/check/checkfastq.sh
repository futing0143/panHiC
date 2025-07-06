#!/bin/bash

cd /cluster2/home/futing/Project/panCancer/TALL

# find . -name '*_2.fastq.gz' -exec basename {} _2.fastq.gz \; | while read srr;do
# 	gunzip -t ${srr}*.fastq.gz
# done

for i in SRR8939328 SRR8939329;do
	gunzip -t ${i}_1.fastq.gz
	gunzip -t ${i}_2.fastq.gz
done


