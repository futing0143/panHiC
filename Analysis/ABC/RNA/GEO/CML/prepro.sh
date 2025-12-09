#!/bin/bash

wkdir=/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/CML
awk 'NR==FNR {meta[$1]=$2; next} 
     FNR==1 {for(i=2;i<=NF;i++) if($i in meta) $i=meta[$i]; print; next}
     {print}' ${wkdir}/metadata.txt <(head -n1 ${wkdir}/GSE137374_raw_counts_GRCh38.p13_NCBI.tsv) \
	 | tr ' ' '\n' | xargs -I {} basename {} _RNAseq  | tr '\n' '\t' | sed 's/\t$/\n/' > CML_gene_count.tsv

tail -n +2 ${wkdir}/GSE137374_raw_counts_GRCh38.p13_NCBI.tsv >> CML_gene_count.tsv
cut -f1-3 CML_gene_count.tsv > tmp && mv tmp CML_gene_count.tsv
awk 'NR==FNR {meta[$1]=$2; next} 
     FNR==1 {for(i=2;i<=NF;i++) if($i in meta) $i=meta[$i]; print; next}
     {print}' ${wkdir}/metadata.txt <(head -n1 ${wkdir}/GSE137374_raw_counts_GRCh38.p13_NCBI.tsv) \
	 | tr ' ' '\n' | xargs -I {} basename {} _RNAseq  | tr '\n' '\t' | sed 's/\t$/\n/' > CML_TPM.tsv

tail -n +2 ${wkdir}/GSE137374_norm_counts_TPM_GRCh38.p13_NCBI.tsv >> CML_TPM.tsv
cut -f1-3 CML_TPM.tsv > tmp && mv tmp CML_TPM.tsv

# 替换 entrez id 
RNAanno=/cluster2/home/futing/ref_genome/hg38_gencode/geneID.bed
awk '
BEGIN{ FS1="\t"; FS2="," }
NR==FNR{
    if(NR>1) map[$3]=$1;  # file1: entrez → ensembl
    next
}
FNR==1{
    print $0; next;
}
{
    split($0, a, ",");
    if (a[1] in map) a[1]=map[a[1]];
    # 重新拼接输出
    printf "%s", a[1];
    for(i=2;i<=length(a);i++) printf ",%s", a[i];
    printf "\n";
}
' ${RNAanno} CML_gene_count.csv > output.csv && mv output.csv CML_gene_count.csv

