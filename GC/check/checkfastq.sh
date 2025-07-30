#!/bin/bash


cd /cluster2/home/futing/Project/panCancer/GC
# find . -name '*_R2.fastq.gz' -exec basename {} '_R2.fastq.gz' \; | sort | uniq> ./meta/done.txt


# grep -w -F -v -f ./meta/done.txt ./meta/GC.txt > ./meta/GCundone.txt

# find ./undone/ -type d -exec basename {} \; > ./undone/undonep1.txt

# grep -w -F -v -f ./undone/undonep1.txt ./meta/GCundone.txt > undonep2.txt


find . -name '*_R2.fastq.gz' | while read -r file;do

	name=$(basename $file _R2.fastq.gz)
	echo "Processing ${name}.."
	gunzip -t ${file}
	gunzip -t ${file%%_R2.fastq.gz}_R1.fastq.gz
done