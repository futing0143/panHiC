pacman::p_load(biomaRt,GenomicFeatures,tidyverse,dplyr,purrr)


# ---- merge ALL !!! 
# 输入包括
CCLE=read.csv('/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/CCLE/CCLE_ENSEMBL_TPM.csv',check.names = F)
ENCODE=read.csv('/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/ENCODE/ENCODE_TPM.txt',sep='\t',check.names = F)
GEO=read.csv('/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/mergedp123_TPM.csv',check.names = F)
MB=read.csv('/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/MB/MB_ENSEMBL_TPM.csv',check.names = F)
colnames(ENCODE)[1]='GeneID'
datasets <- list(CCLE = CCLE, ENCODE = ENCODE, GEO = GEO, MB = MB)
sapply(datasets, dim)
datasets_fil=sapply(datasets,function(x){
  x<-x %>%
    group_by(GeneID) %>%
    summarise(across(where(is.numeric), \(x) sum(x, na.rm = TRUE)),
              .groups = "drop"
    )%>%
    column_to_rownames(var="GeneID") %>%
  filter(if_any(everything(), ~ !is.na(.))) %>%
    rownames_to_column(var="GeneID")
})

merged_data <- purrr::reduce(datasets_fil, full_join, by = "GeneID")

data <- merged_data %>% column_to_rownames(var = "GeneID") %>%
  filter(rowSums(!is.na(.) & . != 0, na.rm = TRUE) > 0)
geneids <- getBM(attributes=c('entrezgene_id', 'ensembl_gene_id', 'hgnc_symbol'),
                 filters='ensembl_gene_id',
                 values=rownames(data),
                 mart=ensembl)
data <- data %>% rownames_to_column(var="GeneID")
# ---- 全转换为SYMBOL，方便去掉不重要的基因
TPM_biomart <- left_join(geneids,data,by=c("ensembl_gene_id"="GeneID"))
TPM_biomart <- aggregate(x = TPM_biomart[,3:ncol(TPM_biomart)],   #此时exprSet的第三列开始是表达矩阵内容
                           by = list(symbol = TPM_biomart$hgnc_symbol),   #按照相同symbol分组，在组内计算
                           FUN = max)   %>% #原文中是计算最大值（max），也可以计算平均值（mean）或者中位数（median）
  column_to_rownames(var = 'symbol')
TPM_biomart <- TPM_biomart %>%
  filter(if_any(everything(), ~ !is.na(.))) %>% dplyr::select(-hgnc_symbol)

TPM_fil <- TPM_biomart %>%
  dplyr::select(-exclude)
# ----- 处理好metadata获得去重的矩阵

metadata=colnames(merged_data) %>% as_tibble() 
metadata <- metadata[-1,]
colnames(metadata)='header'
# 使用separate函数，设置分隔符为第一个下划线
metadata <- metadata %>%
  separate(col = "header", 
           into = c("cancer", "cell"), 
           sep = "_", 
           extra = "merge",  # 只分隔第一个下划线
           fill = "left",
           remove=F)   # 如果没有下划线，cell列填充NA
metadata <- metadata %>%
  mutate(clcell=gsub("RNA-Seq_","",cell)) %>%
  dplyr::select(-cell)
exclude=metadata$header[c(339:348,351:354,367:370,373:376,380:457,469:471,475:477,481:489,493:507)]
metadata_fil <- metadata[!metadata$header %in% exclude,]
metadata_fil$cell = metadata_fil$clcell
metadata_fil$isctrl = 0
metadata_fil$Datasource = ifelse(metadata_fil$header %in% colnames(CCLE),
                                 'CCLE',
                                 ifelse(metadata_fil$header %in% colnames(ENCODE),
                                        'ENCODE',
                                        'GEO'))


anno=read.csv('/cluster2/home/futing/Project/panCancer/check/meta/panCan_annometa.txt',sep='\t',check.names = F,header=F)
colnames(anno) = c('cancer','gse','cell','ucell','ncell','isctrl','istreated')
anno <- anno %>%
  dplyr::select('cancer','ucell','isctrl') %>% unique()

anno_sub <- anno %>% dplyr::select(ucell, cancer_anno = cancer)

# 左连接合并数据
metadata_fil <- metadata_fil %>%
  left_join(anno_sub, by = c("cell" = "ucell")) %>%
  mutate(
    cancer = ifelse(is.na(cancer), cancer_anno, cancer)
  ) %>%
  dplyr::select(-cancer_anno)  # 删除临时列

write.table(metadata_fil,'/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/metadata.txt',sep="\t",quote=F,row.names = F)


metadatan <- read.csv('/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/metadata.txt',sep='\t',check.names = F)
