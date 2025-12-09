#!/bin/bash


wkdir=/cluster2/home/futing/Project/panCancer/Analysis/ABC/H3K27ac/GEO/RCC
metafile=${wkdir}/SraRunTable.csv
cd ${wkdir}
IFS=$','
while read -r srr cell enzyme;do

	if [ ! -d ${wkdir}/${cell} ];then

	    mkdir -p ${wkdir}/${cell}
	fi
	echo ${srr} >> ${wkdir}/${cell}/${enzyme}.txt
	mv ${srr}.fastq.gz ${wkdir}/${cell}/
done < <(tail -n +2 $metafile | cut -f1,34,36 -d ',')
