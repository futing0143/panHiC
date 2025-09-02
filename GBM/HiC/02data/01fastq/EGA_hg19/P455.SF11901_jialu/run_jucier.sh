#!/bin/bash

/cluster/home/futing/software/juicer_CPU/scripts/juicer.sh \
	-S final \
	-g hg38 \
	-d /cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA_hg19/P455.SF11901_jialu \
	-p /cluster/home/futing/software/juicer_CPU/restriction_sites/hg38.genome \
	-y /cluster/home/futing/software/juicer_CPU/restriction_sites/hg38_Arima.txt \
	-z /cluster/home/futing/software/juicer_CPU/references/hg38.fa \
	-D /cluster/home/futing/software/juicer_CPU/ 