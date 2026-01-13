#!/bin/bash

cd /cluster2/home/futing/Project/panCancer/Analysis/mutation_load

bedpe=/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}/anno/mustache/${cell}_10k_mustache.bedpe
metadata=/cluster2/home/futing/Project/panCancer/check/meta/panCan_meta.txt
wkdir=/cluster2/home/futing/Project/panCancer/

IFS=$'\t'
while read -r cancer gse cell enzyme;do
	file="${wkdir}/${cancer}/${gse}/${cell}/anno/mustache/${cell}_10kb_mustache.bedpe"
	if [ ! -s $file ];then

		echo "$file not found, skip"
		continue
	else
		echo "$file" >> /cluster2/home/futing/Project/panCancer/Analysis/mutation_load/BRCA_mustache_list.txt
	fi

done < <(grep "BRCA" $metadata)

