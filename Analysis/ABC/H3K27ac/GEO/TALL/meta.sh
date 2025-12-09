#!/bin/bash


wkdir=/cluster2/home/futing/Project/panCancer/Analysis/ABC/H3K27ac/GEO/TALL
metafile=/cluster2/home/futing/Project/panCancer/Analysis/ABC/H3K27ac/GEO/TALL/SraRunTable.csv
cd /cluster2/home/futing/Project/panCancer/Analysis/ABC/H3K27ac/GEO/TALL
IFS=$','
while read -r srr cell enzyme;do

	if [ ! -d ${wkdir}/${cell} ];then

	    mkdir -p ${wkdir}/${cell}
	fi
	echo ${srr} >> ${wkdir}/${cell}/${enzyme}.txt
	mv ${srr}.fastq.gz ${wkdir}/${cell}/
done < <(tail -n +2 $metafile | cut -f1,33,34 -d ',')
