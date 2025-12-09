#!/bin/bash

cell=NUT
gse=NUT

wkdir=/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/${cell}/
cd $wkdir
gunzip *.gz

join -t $'\t' -1 1 -2 1 GSE189729_norm_counts_TPM_GRCh38.p13_NCBI.tsv GSE179693_norm_counts_TPM_GRCh38.p13_NCBI.tsv \
		> NUT_norm_counts_TPM_GRCh38.p13_NCBI.tsv
join -t $'\t' -1 1 -2 1 GSE189729_raw_counts_GRCh38.p13_NCBI.tsv GSE179693_raw_counts_GRCh38.p13_NCBI.tsv \
		> NUT_raw_counts_GRCh38.p13_NCBI.tsv

awk 'NR==FNR {meta[$1]=$2; next} 
     FNR==1 {for(i=2;i<=NF;i++) if($i in meta) $i=meta[$i]; print; next}
     {print}' ${wkdir}/metadata.txt <(head -n1 ${wkdir}/${gse}_raw_counts_GRCh38.p13_NCBI.tsv) \
	 | tr ' ' '\n' | xargs -I {} basename {} _RNAseq  | tr '\n' '\t' | sed 's/\t$/\n/' > ${cell}_gene_count.tsv

tail -n +2 ${wkdir}/${gse}_raw_counts_GRCh38.p13_NCBI.tsv >> ${cell}_gene_count.tsv

awk 'NR==FNR {meta[$1]=$2; next} 
     FNR==1 {for(i=2;i<=NF;i++) if($i in meta) $i=meta[$i]; print; next}
     {print}' ${wkdir}/metadata.txt <(head -n1 ${wkdir}/${gse}_raw_counts_GRCh38.p13_NCBI.tsv) \
	 | tr ' ' '\n' | xargs -I {} basename {} _RNAseq  | tr '\n' '\t' | sed 's/\t$/\n/' > ${cell}_TPM.tsv

tail -n +2 ${wkdir}/${gse}_norm_counts_TPM_GRCh38.p13_NCBI.tsv >> ${cell}_TPM.tsv

cut -f1-3,6-9,14-17 ${cell}_gene_count.tsv > tmp && mv tmp ${cell}_gene_count.tsv
cut -f1-3,6-9,14-17 ${cell}_TPM.tsv > tmp && mv tmp ${cell}_TPM.tsv