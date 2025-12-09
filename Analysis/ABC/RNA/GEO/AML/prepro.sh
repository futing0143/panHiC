#!/bin/bash
cd /cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/AML
# expected count
echo "GeneID,PBMC_rep1,PBMC_rep2,PBMC_rep3" > PBMC_gene_count.csv
python /cluster2/home/futing/pipeline/RNA/feature-count-extract.py 5 PBMC_rep1_RSEM.txt PBMC_rep2_RSEM.txt PBMC_rep3_RSEM.txt \
| sed 's/\t/,/g' \
| awk 'BEGIN{FS=OFS=","} NR==1{print; next} {sub(/\..*/, "", $1); print}'>> PBMC_gene_count.csv


echo "GeneID,PBMC_rep1,PBMC_rep2,PBMC_rep3" > PBMC_TPM.csv
python /cluster2/home/futing/pipeline/RNA/feature-count-extract.py 6 PBMC_rep1_RSEM.txt PBMC_rep2_RSEM.txt PBMC_rep3_RSEM.txt \
| sed 's/\t/,/g' \
| awk 'BEGIN{FS=OFS=","} NR==1{print; next} {sub(/\..*/, "", $1); print}'>> PBMC_TPM.csv