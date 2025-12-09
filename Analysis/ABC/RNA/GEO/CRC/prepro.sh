#!/bin/bash
cell=CRC
gse=GSE207949

wkdir=/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/${cell}/
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
