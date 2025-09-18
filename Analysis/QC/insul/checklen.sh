#!/bin/bash


IFS=$'\t' 
while read -r cancer gse cell ncell; do
	file="/cluster2/home/futing/Project/panCancer/${cancer}/$gse/$cell/anno/insul/${cell}_5000.tsv"
	linecount=$(wc -l < "$file")
	if [ $linecount -ne 617670 ]; then
		echo "$file" >> checklen.txt
	fi
done < "/cluster2/home/futing/Project/panCancer/check/hic/insul0910.txt"