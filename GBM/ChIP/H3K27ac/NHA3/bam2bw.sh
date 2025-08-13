#!/bin/bash

cd /cluster/home/futing/Project/GBM/ChIP/H3K27ac/NHA3
source activate HiC
for i in SRR25404260;do
	bamCompare -b1 ./bam_files/${i}.rmdup_sorted.bam \
		-b2 ./bam_files/SRR25404258.rmdup_sorted.bam \
		-o ./bigwig/${i}_input.bw \
		--scaleFactorsMethod SES \
		--operation log2 \
		--binSize 20 \
		--smoothLength 60 \
		--extendReads 150 \
		--numberOfSamples 50000000 \
		--centerReads

done
