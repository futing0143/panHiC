#!/bin/bash

# 筛选 Enhancer 与 HARs overlap
workdir=/cluster/home/futing/Project/GBM/HiC/HAR/HARs_gene/diffEn

sort -k1,1 -k2,2n ${workdir}/GBM_vs_NPC_deseq2_all.bed > tmp && mv tmp ${workdir}/GBM_vs_NPC_deseq2_all.bed
cut -f1-3 ${workdir}/GBM_vs_NPC_deseq2_all.bed > ${workdir}/GBM_vs_NPC_deseq2_all.bed3

pairToBed -a /cluster/home/futing/Project/GBM/HiC/HAR/HARs_gene/EPs/GBM_HARs.bedpe \
	-b ${workdir}/GBM_vs_NPC_deseq2_all.bed3 > ${workdir}/GBM_vs_NPC_deseq2_all.bedpe