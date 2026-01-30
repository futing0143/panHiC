#!/bin/bash
# find /cluster2/home/futing/Project/panCancer/Analysis/ABC/ATAC/GEO/ \
# -type f -regextype posix-extended   -regex '.*/GSM[0-9]+(\.fastq.gz)?$' -exec dirname {} \; \
# | sort -u > ATACtest_se.tsv


metafile=/cluster2/home/futing/Project/panCancer/Analysis/ABC/ATAC/GEO/new/ATACtest.tsv
IFS=$'\t'
while read -r cancer gse id;do
	dir=/cluster2/home/futing/Project/panCancer/Analysis/ABC/ATAC/GEO/${cancer}/${gse}/${id}
	bash /cluster2/home/futing/pipeline/newATAC/mvATACfile.sh -d ${dir} -n ${id}

done < <(tail -n +2 ${metafile} | cut -f1,7,10 | sort -u| grep -v 'GM12878')
