pacman::p_load(biomaRt,GenomicFeatures,tidyverse)
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

write.table(exonic.gene.sizes_new,'exon_length.txt')


##------------------------------- 02.convert count to TPM ------------------------------------##
input=read.csv('/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/mergedp2_gene_count.csv',check.names=F)

#### merge gene length and count####
matrix <- merge(exonic.gene.sizes,input,by='GeneID') %>%
  column_to_rownames(.,var='GeneID')


###----------- TPM = (count/genelength)*1e6/sum[gc1/l1+gc2/l2+c3/l3+...+cn/ln] ------------###

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
TPM_feature <- TPM_feature %>% rownames_to_column(var='GeneID')
TPM_feature <- TPM_feature %>% filter(if_any(everything(), ~ !is.na(.)))
write.csv(TPM_feature,'/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/mergedp2_TPM.csv',row.names=F,quote=F)
