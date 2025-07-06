#!/bin/bash
cd /cluster2/home/futing/Project/panCancer/TALL
IFS=$','
while read -r gse gsm srr cell other;do
	mkdir -p ${gse}/${cell}
	echo -e "mv ${srr}*.fastq.gz ${gse}/${cell}/"
	mv ${srr}*.fastq.gz ${gse}/${cell}/
	
done < <(tail -n +2 '/cluster2/home/futing/Project/panCancer/TALL/TALL_anno.csv')