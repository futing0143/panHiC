#!/bin/bash

wkdir=/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/BLCA
awk 'BEGIN{FS="\t";OFS=","}{print $1,$8,$9,$10,$11,$2,$13}' \
	/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/BLCA/GSE267762_gene_count_matrix_WT_KO.txt \
	> ${wkdir}/BLCA_gene_count.csv