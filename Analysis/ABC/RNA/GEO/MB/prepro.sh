#!/bin/bash

wkdir=/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/MB
join -t $'\t' -1 1 -2 1 \
    <(sort -t $'\t' -k1,1d ${wkdir}/GSM3770745_Daoy_cont_sh_1_Genes_ReadCount.txt) \
    <(sort -t $'\t' -k1,1d ${wkdir}/GSM3770746_Daoy_cont_sh_2_Genes_ReadCount.txt) \
| tr '\t' ',' > MB_gene_count.csv

