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
# BL HumanBcell BLCA ES MB PBMC
# 2026.1.2 多了个PBMC
find /cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO   -name '*_gene_count.csv' \
 -exec sh -c 'cut -f1 "$1" -d "," | head -n3' _ {} \;
# MB 是 symbol 改名为 /cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/MB/MB_SYMBOL_gene_count.csv

python /cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/mergefile.py \
    /cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO \
    --end _gene_count.csv \
    --sep ',' \
    -o mergedp2_gene_count.csv
# count2TPM.R 转换为 mergedp2_TPM.csv

# BL HumanBcell BLCA ES GBM PBMC 不重复的
python /cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/mergefile.py \
    /cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO \
    --end _gene_count.csv \
    --sep ',' \
    -o mergedp2_gene_countwithGBM.csv

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

# gene_count
python /cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/mergefile.py \
    /cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO \
    --end _gene_count.tsv \
    --sep '\t' \
    -o mergedp3_gene_count.tsv

# 一共14个
python /cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/mergefile.py \
    /cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO \
    --end _TPM.tsv \
    --sep '\t' \
    -o mergedp3_TPM.tsv
# 接着用transID_mergedp3.R转换为ENSG，得到mergedp3_TPM.csv

# -------------- csv; ENTREZ_ID
# 为什么不和mergedp1合并？ TPM 和 ENSG
# MB /cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/MB/MB_ENSEMBL_TPM.csv
# CCRF-CEM /cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/TALL/CCRF-CEM_ENSEMBL_TPM.csv
# 2026.1.2: MB 直接从 SYMBOL 合并，CCRF 实际上是 leukemia T cell 不用这个数据了
python /cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/mergefile.py \
    /cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO \
    --end _ENSEMBL_TPM.csv \
    --sep ',' \
    -o mergedp4_TPM.tsv

# -------------- Step 2： 经过count2TPM; ENTREZID2ENSEMBL，得到mergedp123_TPM.csv
# mergedp123 MB_ENSEMBL
python /cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/mergefile_p123.py \
/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/01processed \
--end _TPM.csv \
--sep ',' \
-o mergedp123_TPM0102.csv

# mergedp23 MB_ENSEMBL
python /cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/mergefile_p123.py \
/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/01processed \
--end _gene_count.tsv \
--sep '\t' \
-o mergedp23_gene_count0102.tsv
