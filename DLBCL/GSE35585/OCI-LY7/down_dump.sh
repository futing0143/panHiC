#!/bin/bash


source activate /cluster2/home/futing/miniforge3/envs/RNA
prefetch --max-size 150G SRR25419538

if [ -f SRR25419538/SRR25419538.sra ]; then
	echo "File downloaded successfully."
	parallel-fastq-dump --sra-id SRR25419538 --threads 40 --outdir ./ --split-3 --gzip

else
	echo "File download failed."
fi