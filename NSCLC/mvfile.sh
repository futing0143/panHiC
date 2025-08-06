#!/bin/bash

cd /cluster2/home/futing/Project/panCancer/NSCLC/
# tail -n +2 NSCLC.tsv | cut -f1,3,4,9,5 > NSCLC_meta_srr.txt
# tail -n +2 NSCLC.tsv | cut -f1,4,9 | sort -u > NSCLC_meta.txt
IFS=$'\t' 
while read -r gse srr cell genotype enzyme;
do
	mkdir -p ${gse}/${cell}
	echo -e "mv ${gse}/${srr}*.fastq.gz ${gse}/${cell}"
	mv ${gse}/${srr}*.fastq.gz ${gse}/${cell}
done < 'NSCLC_meta_srr.txt'

IFS=$'\t' 
while read -r gse srr cell enzyme;
do
	sh /cluster2/home/futing/Project/panCancer/NSCLC/sbatch.sh ${gse} ${cell}
done < 'NSCLC_meta.txt'
