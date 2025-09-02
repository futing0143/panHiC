#!/bin/bash

source /cluster/home/futing/miniforge-pypy3/etc/profile.d/conda.sh
conda activate homer

for i in GBM NHA iPSC NPC; do
	echo -e "Processing ${i}...\n"
	mkdir /cluster/home/futing/Project/GBM/HiC/hubgene/new/chip/motif/${i}
	findMotifsGenome.pl /cluster/home/futing/Project/GBM/HiC/hubgene/new/chip/motif/filtered_${i}_chip_Enhanceronly.bed \
		hg38 /cluster/home/futing/Project/GBM/HiC/hubgene/new/chip/motif/${i}
done
