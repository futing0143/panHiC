#!/bin/bash

# 合并ENCODE数据
files=()
for cell in OCI-LY7 SJCRH30 MG-63 NCI-H460 GM12878;do
	metafile=/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/${cell}/*.tsv

	tail -n +2 ${metafile} | cut -f1,5 | sort -k1,1n > ${metafile%.tsv}_IDmap.txt
	files+=("${metafile%.tsv}_IDmap.txt")
done 

tmp="${files[0]}"
for f in "${files[@]:1}"; do
    join -a1 -a2 -e '.' -o auto "$tmp" "$f" > tmp_merged
    mv tmp_merged "$tmp"
done

mv "$tmp" merged.txt
