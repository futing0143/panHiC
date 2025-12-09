#!/bin/bash

wkdir=/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/ALL
join -1 1 -2 1 -t $'\t' ${wkdir}/GSM4349487_GM12878_CC_RNA-seq_rep1_gene.TPM.txt \
	${wkdir}/GSM4349488_GM12878_CC_RNA-seq_rep2_gene.TPM.txt \
	| awk 'BEGIN{FS=OFS="\t"} NR==1{print; next} {sub(/\..*/, "", $1); print}' > ${wkdir}/GM12878_TPM.tsv

sed -i 's/\t/,/g' ${wkdir}/GM12878_TPM.tsv 
mv ${wkdir}/GM12878_TPM.tsv ${wkdir}/GM12878_TPM.csv