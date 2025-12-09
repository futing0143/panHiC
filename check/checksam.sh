#!/bin/bash

IFS=$'\t'
while read -r cancer gse cell;do
	echo -e "Checking ${cancer}/${gse}/${cell}...\n"
	find /cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell} -type f -name "*.fastq.gz.sam" | \
	while read -r file; do
		if [ -f "${file%.sam}.bam" ]; then
			srr=$(basename "$file" .fastq.gz.sam)
			echo "${cancer}\t${gse}\t${cell}\t${srr}" >> /cluster2/home/futing/Project/panCancer/check/sam2bam/sam_bam_1207.txt
		else
			echo "SAM converted: $file"
		fi
	done

done < "/cluster2/home/futing/Project/panCancer/check/sam2bam/sam2bam_1206.txt"