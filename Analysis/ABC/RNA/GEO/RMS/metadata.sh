#!/bin/bash

wkdir=/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/RMS/
cut -f1,5-13 ${wkdir}/GSE253892_RNAseq_raw_counts_table.txt > RMS_gene_count.csv

