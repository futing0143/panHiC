pacman::p_load(biomaRt,GenomicFeatures,tidyverse,rtracklayer)
setwd('/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO')

# ------------------ 01 exon length
txdb <- makeTxDbFromGFF("/cluster2/home/futing/ref_genome/hg38_gencode/genebed/gencode.v43.annotation.gtf",format="gtf")
exons.list.per.gene <- exonsBy(txdb,by="gene")
# baseR的写法是最快的，不用修改了
exonic.gene.sizes <- as.data.frame(sum(width(GenomicRanges::reduce(exons.list.per.gene))))
colnames(exonic.gene.sizes) = 'GeneLen'

exonic.gene.sizes <- exonic.gene.sizes %>%
  rownames_to_column(var = "Gene") %>%
  as_tibble() %>%
  mutate(GeneID = sub("\\..*$", "", Gene)) %>%
  dplyr::select(GeneID, GeneLen) %>%
  unique() #发现parX parY长度都是一样的，故直接unique()
dup_rows <- exonic.gene.sizes_new %>%
  group_by(GeneID) %>%
  filter(n() > 1)

# 从GTF提取mapping
gtf <- import("/cluster2/home/futing/ref_genome/hg38_gencode/genebed/gencode.v43.annotation.gtf")
gene_map <- unique(mcols(gtf[gtf$type == "gene"])[, c("gene_id", "gene_name")]) %>% 
  as_tibble() %>%
  mutate(GeneID=sub("\\..*$", "", gene_id)) %>%
  merge(.,exonic.gene.sizes,by='GeneID',all=T) %>%
  dplyr::select(GeneID,gene_name,GeneLen)
colnames(gene_map) = c("GeneID","SYMBOL","GeneLen")

write_tsv(gene_map,"/cluster2/home/futing/ref_genome/hg38_gencode/genelength.txt")


# -------- 02 read in files
input=read.csv('/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/TALL/CCRF-CEM_raw_counts_GRCh38.p13_NCBI.tsv',sep='\t',check.names = F)
input <- as_tibble(input) %>%
  group_by(GeneID) %>%
  summarise(
    across(where(is.numeric), \(x) mean(x, na.rm = TRUE)),
    .groups = "drop"
  ) 
input$GeneID <- as.character(input$GeneID)
hg_symbols <- getBM(attributes=c('entrezgene_id', 'ensembl_gene_id'),
                    filters='entrezgene_id',
                    values=input$GeneID,
                    mart=ensembl)
count_biomart <- left_join(hg_symbols,input,by=c("ensembl_gene_id"="GeneID"))
count_biomart <- aggregate(x = count_biomart[,3:ncol(count_biomart)],   #此时exprSet的第三列开始是表达矩阵内容
                           by = list(GeneID = count_biomart$ensembl_gene_id),   #按照相同symbol分组，在组内计算
                           FUN =function(x){
                             sum(x,na.rm=T)})  #原文中是计算最大值（max），也可以计算平均值（mean）或者中位数（median）
head(count_biomart)

matrix=merge(count_biomart,gene_map[,c(1,3)],by='GeneID') %>%
  group_by(GeneID) %>%
  summarise(
    GeneLen = dplyr::first(GeneLen),  # 保留GeneLen,取第一个值
    across(where(is.numeric), \(x) sum(x, na.rm = TRUE)),
    .groups = "drop"
  )%>% column_to_rownames(var="GeneID")

TPM_feature <- apply(matrix[,-1], 2, function(x) {
  x <- as.numeric(x)
  L <- matrix$GeneLen
  # 避免除以0或NA
  L[L == 0 | is.na(L)] <- NA
  rate <- x / L
  # sum(rate, na.rm=TRUE) 避免 NA
  denom <- sum(rate, na.rm = TRUE)
  if (denom == 0) return(rep(0, length(x)))
  return(rate * 1e6 / denom)
}) %>% as.data.frame()

rownames(TPM_feature) <- rownames(matrix)
TPM_feature <- TPM_feature %>% rownames_to_column(var='GeneID') %>% 
  filter(if_any(everything(), ~ !is.na(.)))
write.csv(TPM_feature,'/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/TALL/CCRF-CEM_ENSEMBL_TPM.csv',row.names=F,quote=F)
