#!/bin/bash

# ========= 合并的前提是全部ENSG

# ----------- csv；TPM；ENSG
# GBM HCC NPC GM12878 PBMC 
find /cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO \
  -name '*_TPM.csv' \
  -exec sh -c 'cut -f1 "$1" -d "," | head -n3' _ {} \;

python /cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/mergefile.py \
	/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO \
	--end _TPM.csv \
	--sep ',' \
	-o mergedp1_TPM.csv

# ------------ csv；gene_count；ENSG
# BL HumanBcell BLCA ES MB 不重复的
find /cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO   -name '*_gene_count.csv' \
 -exec sh -c 'cut -f1 "$1" -d "," | head -n3' _ {} \;
# MB 是 symbol 改名为 /cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/MB/MB_SYMBOL_gene_count.csv

python /cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/mergefile.py \
	/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO \
	--end _gene_count.csv \
	--sep ',' \
	-o mergedp2_gene_count.csv
# count2TPM.R 转换为 mergedp2_TPM.csv

# -------------- tsv; ENTREZ_ID
# 看一下哪些是单独的，TPM的是全的，只合并TPM的结果
find /cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO -name '*_gene_count.tsv' \
	-exec basename {} _gene_count.tsv \; > NCBI_ENTREZID.txt
find /cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO -name '*_TPM.tsv' \
	-exec basename {} _TPM.tsv \; > NCBI_TPM_ENTREZID.txt
comm -13 NCBI_ENTREZID.txt NCBI_TPM_ENTREZID.txt


find /cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO \
  -name '*_TPM.tsv' \
  -exec sh -c 'cut -f1 "$1" | head -n3' _ {} \;

# 一共13个
python /cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/mergefile.py \
	/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO \
	--end _TPM.tsv \
	--sep '\t' \
	-o mergedp3_TPM.tsv
# 接着用transID.R转换为ENSG，得到mergedp3_TPM.csv

# -------------- csv; ENTREZ_ID
# MB /cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/MB/MB_ENSEMBL_TPM.csv
# CCRF-CEM /cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/TALL/CCRF-CEM_ENSEMBL_TPM.csv
python /cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/mergefile.py \
	/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO \
	--end _ENSEMBL_TPM.csv \
	--sep ',' \
	-o mergedp4_TPM.tsv

# -------------- Step 2： 经过count2TPM; ENTREZID2ENSEMBL，得到mergedp123_TPM.csv
# mergedp123 MB_ENSEMBL
python /cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/mergefile_p123.py \
	/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO \
	--end _TPM.csv \
	--sep ',' \
	-o mergedp1234_TPM.csv

