#!/bin/bash

cd /cluster/home/futing/Project/GBM/ChIP/H3K27ac/U87_new

for i in SRR14862242 SRR14862243;do
	bamCompare -b1 ./bam_files/${i}.rmdup_sorted.bam \
		-b2 ./bam_files/SRR14862252.rmdup_sorted.bam \
		-o ./bigwig/${i}_input.bw \
		--scaleFactorsMethod SES \
		--operation log2 \
		--binSize 20 \
		--smoothLength 60 \
		--extendReads 150 \
		--numberOfSamples 50000000 \
		--centerReads

done