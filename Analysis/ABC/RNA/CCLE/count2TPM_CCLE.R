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


write.table(exonic.gene.sizes,'exon_length.txt')


##------------------------------- 02.convert count to TPM ------------------------------------##
CCLE_raw=read.csv('/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/CCLE/CCLE_panCan_rawcount.txt',sep='\t',check.names = F)
input <- as_tibble(CCLE_raw) %>% 
  group_by(cell_line_display_name) %>%
  summarise(
    across(where(is.numeric), \(x) mean(x, na.rm = TRUE)),
    .groups = "drop"
  ) %>% 
  column_to_rownames(var = "cell_line_display_name") %>%
  t()
# SYMBOL (ENTREZID) 拆开去掉ENSG结尾的.
genenames <- rownames(input) %>% 
  as_tibble() %>%
  mutate(
    SYMBOL   = sub(" \\(.*", "", value),
    ENTREZID = sub(".*\\((.*)\\)", "\\1", value)
  ) %>%
  mutate(
    SYMBOL   = sub("\\..*", "", SYMBOL),
    ENTREZID = sub("\\..*", "", ENTREZID)
  )

# ----------- method1 biomaRt 
mapping_ENTREZID <- getBM(attributes=c('entrezgene_id', 'ensembl_gene_id', 'hgnc_symbol'),
                 filters='entrezgene_id',
                 values=genenames$ENTREZID,
                 mart=ensembl)
mapping_SYMBOL <- getBM(attributes=c('ensembl_gene_id', 'hgnc_symbol','start_position', 'end_position', 
                                     'chromosome_name'),
                          filters='hgnc_symbol',
                          values=genenames$SYMBOL,
                          mart=ensembl)
mapping_SYMBOL$genelength=abs(mapping_SYMBOL$end_position - mapping_SYMBOL$start_position)
colnames(mapping_SYMBOL)[c(1,2,6)]=c('ENSEMBL','SYMBOL',"GeneLen")

biomart_result = left_join(genenames[,c(1:3)],mapping_SYMBOL,by='SYMBOL') %>% unique()

# duplcated 的来源于SYMBOL对应多个ENTREZID
dup_rows <-biomart_result%>%
  group_by(value,ENSEMBL) %>%
  filter(n() > 1)
biomart_result$ENSEMBL=ifelse(is.na(biomart_result$ENSEMBL),
                              biomart_result$SYMBOL,
                              biomart_result$ENSEMBL
                              )
dup_rows2 <-biomart_result%>%
  group_by(value) %>%
  filter(n() > 1)
# 一个value 对应多个ENSG

# ----------- method2 org.Hs.eg.db
ens <- mapIds(org.Hs.eg.db,
              keys = genenames$SYMBOL,
              column = "ENSEMBL",
              keytype = "SYMBOL",
              multiVals = "first")
ent <- mapIds(org.Hs.eg.db,
              keys = genenames$ENTREZID,
              column = "ENSEMBL",
              keytype = "ENTREZID",
              multiVals = "first")

# 优先 ENSEMBL，其次 ENTREZID
FinalID <- ifelse(
  !is.na(ens),             # 1. 优先 ENSEMBL
  ens,
  ifelse(
    !is.na(ent),         # 2. 其次 ENTREZID
    ent,
    genenames$SYMBOL             # 3. 最后用 genes 自己
  )
)

genenames$ENSG =FinalID
dup_rows1 <- genenames %>%
  group_by(ENSG) %>%
  filter(n() > 1)

# --- 合并
matrix1 <- merge(input, biomart_result[,c('value','ENSEMBL','GeneLen')], 
                by.x=0, by.y='value') %>%
  dplyr::select(-1) %>%
  dplyr::select(ncol(.)-1, ncol(.), everything()) %>%
  group_by(ENSEMBL) %>%
  summarise(
    GeneLen = dplyr::first(GeneLen),  # 保留GeneLen,取第一个值
    across(where(is.numeric) & !GeneLen, \(x) sum(x, na.rm = TRUE)),
    .groups = "drop"
  )#还是os的结果更好一些

input2 <- merge(input, genenames[, c('value', 'ENSG')], by.x = 0, by.y = 'value') %>%
  dplyr::select(-1) %>%
  dplyr::select(ncol(.), everything()) %>%
  as_tibble() %>%
  group_by(ENSG) %>%
  summarise(
    across(where(is.numeric), \(x) sum(x, na.rm = TRUE)),
    .groups = "drop"
  )
colnames(input3)[1]='GeneID'
matrix2 <- merge(exonic.gene.sizes,input2,by='GeneID') %>% #merge gene length and count
  column_to_rownames(.,var='GeneID')

# ------ method 3 直接从gtf中获得SYMBOL的长度
gene_map1=merge(gene_map,genenames[,c('value','SYMBOL')],by.x='gene_name',by.y='SYMBOL')
matrix3 <- merge(gene_map1,input,by.x='value',by.y=0) %>% 
  dplyr::select(-value,-gene_name)
save(matrix1,matrix2,matrix3,gene_map,genenames,mapping_SYMBOL,input,file="CCLE_count2TPM.RData")

###----------- TPM = (count/genelength)*1e6/sum[gc1/l1+gc2/l2+c3/l3+...+cn/ln] ------------###
matrix3 <- matrix3  %>%
  group_by(GeneID) %>%
  summarise(
    GeneLen = dplyr::first(GeneLen),  # 保留GeneLen,取第一个值
    across(where(is.numeric) & !GeneLen, \(x) sum(x, na.rm = TRUE)),
    .groups = "drop"
  )%>% column_to_rownames(var="GeneID")
TPM_feature <- apply(matrix3[,-1], 2, function(x) {
  x <- as.numeric(x)
  L <- matrix3$GeneLen
  # 避免除以0或NA
  L[L == 0 | is.na(L)] <- NA
  rate <- x / L
  # sum(rate, na.rm=TRUE) 避免 NA
  denom <- sum(rate, na.rm = TRUE)
  if (denom == 0) return(rep(0, length(x)))
  return(rate * 1e6 / denom)
}) %>% as.data.frame()

rownames(TPM_feature) <- rownames(matrix3)
TPM_feature <- TPM_feature %>% rownames_to_column(var='GeneID') %>% 
  filter(if_any(everything(), ~ !is.na(.)))
write.csv(TPM_feature,'/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/CCLE/CCLE_ENSEMBL_TPM.csv',row.names=F,quote=F)
