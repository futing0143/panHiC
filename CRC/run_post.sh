#!/bin/bash


IFS=$'\t' 
while read -r gse cell tools;do
	sh /cluster2/home/futing/Project/panCancer/CRC/sbatch_post.sh ${tools} ${cell} ${gse}
done < '/cluster2/home/futing/Project/panCancer/CRC/check/check_July02.txt'
