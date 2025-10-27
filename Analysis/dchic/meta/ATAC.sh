#!/bin/bash


IFS=$','
while read -r path type cell cancer;do
	cd /cluster2/home/futing/Project/panCancer/Analysis/dchic
	echo "mving ${path}/bwa to ${cell}"
	mkdir -p ${cell}
	rsync -avh --progress ${path}/bwa/* ${cell}/

done < "/cluster2/home/futing/Project/panCancer/Analysis/dchic/meta/ATAC_fil.csv"