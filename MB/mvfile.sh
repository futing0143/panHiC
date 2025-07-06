#!/bin/bash

cd /cluster2/home/futing/Project/panCancer/MB
IFS=$','
while read -r gse gsm srr cell other;do

	mkdir -p ${gse}/${cell}
	echo "mv ${srr} to ${gse}/${cell}"
	mv ${srr}/* ${gse}/${cell}
done < <(tail -n +2 'MB_anno.csv')

# find /cluster2/home/futing/Project/panCancer/MB/GSE240410 -name '*_2.fastq.gz' -exec basename {} _2.fastq.gz \;

# 整理 MB_anno.csv 至 MB_meta.txt
# tail -n +2 /cluster2/home/futing/Project/panCancer/MB/MB_anno.csv \
	# | cut -f1,4 -d ',' | sort | uniq | awk 'BEGIN{FS=OFS=","}{print $0,"MobI"}'> MB_meta.txt


# sh /cluster2/home/futing/Project/panCancer/MB/sbatch.sh GSE240410 MB275 MboI


for i in MB174 MB199 MB227 MB268 MB277 MB288;do

	mkdir -p GSE240410/${i}/fastq
	find . -maxdepth 1 -name "*${i}*" -exec mv {} GSE240410/${i}/fastq/ \;

done