#!/bin/bash


cd /cluster/home/futing/Project/GBM/HiC/UCSC/GBM/HARs_RNA


dir=/cluster/home/futing/Project/GBM/HiC/UCSC/GBM/HARs_RNA/hicsame
find $dir -name "*.pdf" | while read filepath;do
	filename=$(basename $filepath)
	echo 
	# mv $i ./hicsame/${filename}
done