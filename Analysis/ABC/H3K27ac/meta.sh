#!/bin/bash

cd /cluster2/home/futing/Project/panCancer/Analysis/ABC/H3K27ac
ENCODEmeta=/cluster2/home/futing/Project/panCancer/Analysis/ABC/H3K27ac/metadata_encode.tsv
H3K27acdir=/cluster2/home/futing/Project/panCancer/Analysis/ABC/H3K27ac/ENCODE

tail -n +2 $ENCODEmeta | cut -f1,11 | \
	awk -v dir=$H3K27acdir 'BEGIN{FS=OFS="\t"}{print $1,$2,$2,dir"/"$2"/"$1".bed.gz"}' > ENCODE_H3K27ac.txt
IFS=$'\t'
while read -r file cell path;do
	mkdir ./ENCODE/${cell}
	mv ${file}.bed.gz ./ENCODE/${cell}
done < "ENCODE_H3K27ac.txt"



meta=/cluster2/home/futing/Project/panCancer/check/meta/panCan_annometa.txt
cp $meta H3K27ac.txt

