#!/bin/bash


# run RNA and mv fastq to /cancer/cell


GSEsrr=/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/GSE_metadata0104_srr.txt
GSEmeta=/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/01processed/GSE_metadata_all.txt
RNAmeta=/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/01processed/RNAmetaGSE0103.txt


join -t $'\t' -1 1 -2 1 \
  <(cut -f1,3 $GSEmeta | sort -k1,1) \
  <(sort -k1,1 $GSEsrr) \
  -o 1.1,1.2,2.2,2.3,2.4 \
  > GSE_srrmeta.txt

join -t $'\t' -1 1 -2 2 \
  <(cut -f1,2,5 $RNAmeta | sort -k1) \
  GSE_srrmeta.txt \
  -o 1.1,1.2,1.3,2.2,2.3,2.4,2.5 \
  > RNA_GSE_srrmeta.txt