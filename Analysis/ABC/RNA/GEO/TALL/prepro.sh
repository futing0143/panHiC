#!/bin/bash

cell=TALL
gse=TALL

wkdir=/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/${cell}/
cd $wkdir
gunzip *.gz

# ======== Raw Counts :合并 CCRF-CEM, GSE130140, GSE115895, GSE182680, GSE230588
echo -e "GeneID\tCCRF-CEM_rep1\tCCRF-CEM_rep2\tCCRF-CEM_rep3" > CCRF-CEM_raw_counts_GRCh38.p13_NCBI.tsv
tail -n +3 ${wkdir}/GSE275161_featureCounts_merged.txt | cut -f1,7-9 >> CCRF-CEM_raw_counts_GRCh38.p13_NCBI.tsv
join -t $'\t' -1 1 -2 1 ${wkdir}/GSE130140_raw_counts_GRCh38.p13_NCBI.tsv \
	${wkdir}/GSE115895_raw_counts_GRCh38.p13_NCBI.tsv | \
	join -t $'\t' -1 1 -2 1 - ${wkdir}/GSE182680_raw_counts_GRCh38.p13_NCBI.tsv | \
	join -t $'\t' -1 1 -2 1 - ${wkdir}/GSE230588_raw_counts_GRCh38.p13_NCBI.tsv \
	> ${wkdir}/TALLp_raw_counts_GRCh38.p13_NCBI.tsv

python /cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/TALL/merge.py \
 ${wkdir}/TALLp_raw_counts_GRCh38.p13_NCBI.tsv ${wkdir}/CCRF-CEM_raw_counts_GRCh38.p13_NCBI.tsv \
 ${wkdir}/TALL_raw_counts_GRCh38.p13_NCBI.tsv
awk 'NR==FNR {meta[$1]=$2; next} 
     FNR==1 {for(i=2;i<=NF;i++) if($i in meta) $i=meta[$i]; print; next}
     {print}' ${wkdir}/metadata.txt <(head -n1 ${wkdir}/${gse}_raw_counts_GRCh38.p13_NCBI.tsv) \
	 | tr ' ' '\n' | sed 's/RNAseq_//g' | tr '\n' '\t' | sed 's/\t$/\n/' > ${cell}_gene_count.tsv
tail -n +2 ${wkdir}/${gse}_raw_counts_GRCh38.p13_NCBI.tsv >> ${cell}_gene_count.tsv

# ======== TPM: 合并 GSE130140, GSE115895, GSE182680, GSE230588
join -t $'\t' -1 1 -2 1 ${wkdir}/GSE130140_norm_counts_TPM_GRCh38.p13_NCBI.tsv \
	${wkdir}/GSE115895_norm_counts_TPM_GRCh38.p13_NCBI.tsv | \
	join -t $'\t' -1 1 -2 1 - ${wkdir}/GSE182680_norm_counts_TPM_GRCh38.p13_NCBI.tsv | \
	join -t $'\t' -1 1 -2 1 - ${wkdir}/GSE230588_norm_counts_TPM_GRCh38.p13_NCBI.tsv > \
	${wkdir}/TALL_norm_counts_TPM_GRCh38.p13_NCBI.tsv

awk 'NR==FNR {meta[$1]=$2; next} 
     FNR==1 {for(i=2;i<=NF;i++) if($i in meta) $i=meta[$i]; print; next}
     {print}' ${wkdir}/metadata.txt <(head -n1 ${wkdir}/${gse}_norm_counts_TPM_GRCh38.p13_NCBI.tsv) \
	 | tr ' ' '\n' | sed 's/RNAseq_//g' | tr '\n' '\t' | sed 's/\t$/\n/' > ${cell}_TPM.tsv

tail -n +2 ${wkdir}/${gse}_norm_counts_TPM_GRCh38.p13_NCBI.tsv >> ${cell}_TPM.tsv

cut -f1-13,18-19,24-26,30-40,44-46,50-52,62-64,82-83,86-90 ${cell}_gene_count.tsv > tmp && mv tmp ${cell}_gene_count.tsv
cut -f1-13,18-19,24-26,30-40,44-46,50-52,62-64,82-83,86-87 ${cell}_TPM.tsv > tmp && mv tmp ${cell}_TPM.tsv