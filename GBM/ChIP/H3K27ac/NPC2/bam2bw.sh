#!/bin/bash

cd /cluster/home/futing/Project/GBM/ChIP/H3K27ac/NPC2

for i in SRR17882759 SRR17882758;do
	bamCompare -b1 ./bam_files/${i}.rmdup_sorted.bam \
		-b2 ./bam_files/input.rmdup_sorted.bam \
		-o ./bigwig/${i}_input.bw \
		--scaleFactorsMethod SES \
		--operation log2 \
		--binSize 20 \
		--smoothLength 60 \
		--extendReads 150 \
		--numberOfSamples 50000000 \
		--centerReads

done