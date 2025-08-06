#!/bin/bash


cd /cluster2/home/futing/Project/panCancer/BRCA/GSE234323/MDA-MB-436/fastq
ls *.fastq.gz | while read -r file; do
	gunzip -t "$file" 2>/dev/null
	if [ $? -ne 0 ]; then
		echo "Error: $file is corrupted or not a valid gzip file." >> checkfastq.log
	else
		echo "File $file is valid." >> checkfastq.log
	fi
done