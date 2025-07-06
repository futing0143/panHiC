#!/bin/bash

source activate HiC
cd 
for i in *_2.fastq.gz;do

	name=$(basename ${i} _2.fastq.gz)
	echo -e "Processing ${name}..."
	gunzip -t ${name}_1.fastq.gz
	gunzip -t ${name}_2.fastq.gz

done