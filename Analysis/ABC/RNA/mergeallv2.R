pacman::p_load(biomaRt,GenomicFeatures,tidyverse,dplyr,purrr)
BiocManager::install("biomaRt")

# =======================
# CCLE 输入为 转换好的SYMBOL * TPM
# ---- merge ALL !!! 
# 输入包括
CCLE_TPM=read.table('/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/CCLE/panCan_CCLE_TPM_cleaned_1225.txt',
              sep='\t',check.names = F,row.names = 1,header=T)
ENCODE=read.csv('/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/ENCODE/ENCODE_TPM.txt',sep='\t',check.names = F)
GEO=read.csv('/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/mergedp1234_TPM.csv',check.names = F)
GBM_GSC=read.csv('/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/GBM/sample/GSE229965_all_GSCs_RNAcounts_ID.txt',sep='\t',check.names=F)

colnames(ENCODE)[1]='GeneID'
datasets <- list(ENCODE = ENCODE, GEO = GEO,GBM=GBM_GSC)
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

# ---- 全转换为SYMBOL，方便去掉不重要的基因
data <- merged_data %>% column_to_rownames(var = "GeneID") %>%
  filter(rowSums(!is.na(.) & . != 0, na.rm = TRUE) > 0)
ensembl <- useMart("ensembl", dataset="hsapiens_gene_ensembl") 
geneids <- getBM(attributes=c('entrezgene_id', 'ensembl_gene_id', 'hgnc_symbol'),
                 filters='ensembl_gene_id',
                 values=rownames(data),
                 mart=ensembl)
geneids$hgnc_symbol <- ifelse(geneids$hgnc_symbol=="",geneids$ensembl_gene_id,geneids$hgnc_symbol)
data <- data %>% rownames_to_column(var="GeneID")
# 按照SYMBOL取均值？why 56105 331
TPM_biomart <- left_join(geneids[,c('ensembl_gene_id','hgnc_symbol')],data,by=c("ensembl_gene_id"="GeneID"))
TPM_biomart_merged <- TPM_biomart %>%
  group_by(hgnc_symbol) %>%
  summarise(across(where(is.numeric),  \(x)mean(x, na.rm = TRUE))) %>%
  column_to_rownames(.,var = 'hgnc_symbol') %>%
  filter(if_any(everything(), ~ !is.na(.)))

TPM_biomart_merged2 = merge(TPM_biomart_merged,CCLE_TPM,by=0,all=T,suffixes=c('_CCLE','_GEO'))

exclude=c('BLCA_5637-KO1-1','G402_CCLE')
TPM_fil2 <- TPM_biomart_merged2 %>%
  dplyr::select(-all_of(exclude)) %>%  #(40299,439)
  column_to_rownames(var='Row.names')
write.table(TPM_fil2,file="/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/results/TPM_fromCCLE_1225.txt",quote=F,sep='\t')

# ----- 处理好metadata获得去重的矩阵

metadata=colnames(TPM_fil2) %>% as_tibble() 
colnames(metadata)='header'


metadata <- metadata %>%
  mutate(Datasource = case_when(
    header %in% colnames(ENCODE) ~ "ENCODE",
    header %in% colnames(CCLE) ~ "CCLE",
    grepl("CCLE", header, ignore.case = TRUE) ~ "CCLE",
    grepl("GEO", header, ignore.case = TRUE) ~ "GEO",
    TRUE ~ "GEO"
  )) %>%
  mutate(
    # 判断header是否包含下划线
    has_underscore = grepl("_", header),
    
    # 判断header是否包含CCLE或GEO
    contains_keyword = grepl("CCLE|GEO", header, ignore.case = TRUE)
  ) %>%
  mutate(
    # cancer逻辑：
    # 1. 如果包含关键词且包含下划线：cancer为空
    # 2. 如果包含下划线但不含关键词：取第一个下划线前的部分
    # 3. 如果不包含下划线：cancer为NA
    cancer = case_when(
      contains_keyword & has_underscore ~ "",
      !contains_keyword & has_underscore ~ sub("_.*", "", header),
      TRUE ~ NA_character_
    ),
    
    # clcell逻辑：
    # 1. 如果包含关键词：取第一个下划线前的部分（如果有下划线），否则取整个header
    # 2. 如果不包含关键词：
    #    - 如果有下划线：取第一个下划线后的部分，并移除"RNA-Seq_"前缀
    #    - 如果没有下划线：clcell = header
    clcell = case_when(
      contains_keyword & has_underscore ~ sub("_.*", "", header),
      contains_keyword & !has_underscore ~ header,
      !contains_keyword & has_underscore ~ gsub("RNA-Seq_", "", 
                                                sub("^[^_]*_", "", header)),
      !contains_keyword & !has_underscore ~ header
    )
  ) %>%
  dplyr::select(-has_underscore, -contains_keyword)


# 直接用之前第一次手动修改好的注释
metadatav2=left_join(metadata,metadatan)

# -------- 用pancan_anno注释cell，添加 cancer istrl 信息
anno=read.csv('/cluster2/home/futing/Project/panCancer/check/meta/panCan_annometa.txt',sep='\t',check.names = F,header=F)
colnames(anno) = c('cancer','gse','cell','ucell','isctrl','istreated','ncell')
anno <- anno %>%
  dplyr::select('cancer','ucell','isctrl') %>% unique()

# 左连接合并数据
metadata_anno <- metadata %>%
  left_join(anno, by = c("clcell" = "ucell")) %>%
  mutate(
    # 优先级：cancer.x不为空且不是"" -> cancer.y -> cancer.x
    cancer = case_when(
      !is.na(cancer.x) & cancer.x != "" ~ cancer.x,
      !is.na(cancer.y) ~ cancer.y,
      TRUE ~ cancer.x  # 或者NA
    )
  ) %>%
  dplyr::select(-cancer.x, -cancer.y)
# metadata_anno$clcell <- trimws(gsub("_+$|_+\\s*$", "", metadata_anno$clcell))
metadata_anno$clcell <- gsub("rep\\s*[0-9]+", "", metadata_anno$clcell, ignore.case = TRUE) #去掉所有rep字段
metadata_anno_sorted <- metadata_anno %>%
  arrange(header, Datasource, clcell)
write.table(metadata_anno_sorted,'/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/metadata1225.txt',sep="\t",quote=F,row.names = F,col.names = F)

# --------- 读入手动处理的数据
metadatan <- read.csv('/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/metadata.txt',sep='\t',check.names = F,header=F)
colnames(metadatan) <- c('header','clcell','Datasource','isctrl','cancer')
