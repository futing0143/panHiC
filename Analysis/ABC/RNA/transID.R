pacman::p_load(clusterProfiler,org.Hs.eg.db,enrichplot,ggplot2,igraph,tidyverse)
load('/cluster2/home/futing/pipeline/RNA/ref/geneinfo.RData')

filepath='/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/MB/MB_gene_count.csv'
filepath='/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/mergedp3_TPM.tsv'
matrix <- read.csv(filepath,check.names = F,sep='\t')

# -------------- 01-1 mapID for mergedp3.tsv
ent <- mapIds(org.Hs.eg.db,
              keys = as.character(matrix$GeneID),
              column = "ENSEMBL",
              keytype = "ENTREZID",
              multiVals = "first")

matrix <- matrix %>%
  mutate(
    GeneID = as.character(GeneID),
    GeneID_new = ent[GeneID],
    GeneID = if_else(is.na(GeneID_new), GeneID, GeneID_new)
  ) %>%
  dplyr::select(-GeneID_new)
write.csv(matrix,'/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/mergedp3_TPM.csv',quote = F,row.names = F)
# -------------- 01 mapID for MB
genes=matrix$GeneID
ens <- mapIds(org.Hs.eg.db,
              keys = genes,
              column = "ENSEMBL",
              keytype = "SYMBOL",
              multiVals = "first")
ent <- mapIds(org.Hs.eg.db,
              keys = genes,
              column = "ENTREZID",
              keytype = "SYMBOL",
              multiVals = "first")

# 优先 ENSEMBL，其次 ENTREZID
FinalID <- ifelse(!is.na(ens), ens, ent)
FinalID <- ifelse(
  !is.na(ens),             # 1. 优先 ENSEMBL
  ens,
  ifelse(
    !is.na(ent),         # 2. 其次 ENTREZID
    ent,
    genes                # 3. 最后用 genes 自己
  )
)

result <- data.frame(SYMBOL = genes, FinalID = FinalID)
newmatrix <- merge(matrix,result,by.x="GeneID",by.y="SYMBOL",all=T)

# ------------- 02 biomaRt

# 连接 Ensembl
ensembl <- useMart("ensembl", dataset="hsapiens_gene_ensembl") # 人类

# 查询 Entrez -> Ensembl
entrez_ids <- c("30964")  # 示例 Entrez IDs
mapping <- getBM(attributes=c('entrezgene_id', 'ensembl_gene_id', 'hgnc_symbol'),
                 filters='entrezgene_id',
                 values=qc$ensembl_gene_id,
                 mart=ensembl)

count_biomart <- left_join(hg_symbols,count,by=c("ensembl_gene_id"="gene_id"))
count_biomart <- aggregate(x = count_biomart[,3:ncol(count_biomart)],   #此时exprSet的第三列开始是表达矩阵内容
                           by = list(symbol = count_biomart$external_gene_name),   #按照相同symbol分组，在组内计算
                           FUN = max)   %>% #原文中是计算最大值（max），也可以计算平均值（mean）或者中位数（median）
  column_to_rownames(var = 'symbol')


# ========== read in mergedp123.csv 然后转为SYMBOL，合并MB

