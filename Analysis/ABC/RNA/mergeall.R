pacman::p_load(biomaRt,GenomicFeatures,tidyverse,dplyr,purrr)
BiocManager::install("biomaRt")

# ---- merge ALL !!! 
# 输入包括
CCLE=read.csv('/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/CCLE/CCLE_ENSEMBL_TPM.csv',check.names = F)
ENCODE=read.csv('/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/ENCODE/ENCODE_TPM.txt',sep='\t',check.names = F)
GEO=read.csv('/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/mergedp1234_TPM.csv',check.names = F)

colnames(ENCODE)[1]='GeneID'
datasets <- list(CCLE = CCLE, ENCODE = ENCODE, GEO = GEO)
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
ensembl <- useMart("ensembl", dataset="hsapiens_gene_ensembl") 
geneids <- getBM(attributes=c('entrezgene_id', 'ensembl_gene_id', 'hgnc_symbol'),
                 filters='ensembl_gene_id',
                 values=rownames(data),
                 mart=ensembl)
geneids$hgnc_symbol <- ifelse(geneids$hgnc_symbol=="",geneids$ensembl_gene_id,geneids$hgnc_symbol)
data <- data %>% rownames_to_column(var="GeneID")
# ---- 全转换为SYMBOL，方便去掉不重要的基因
TPM_biomart <- left_join(geneids[,c('ensembl_gene_id','hgnc_symbol')],data,by=c("ensembl_gene_id"="GeneID"))
TPM_biomart_merged <- TPM_biomart %>%
  group_by(hgnc_symbol) %>%
  summarise(across(where(is.numeric),  \(x) mean(x, na.rm = TRUE))) %>%
  column_to_rownames(.,var = 'hgnc_symbol') %>%
  filter(if_any(everything(), ~ !is.na(.)))


exclude='BLCA_5637-KO1-1'
TPM_fil <- TPM_biomart_merged %>%
  dplyr::select(-exclude) #(40299,439)
write.table(TPM_fil,file="/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/results/TPM_1224.txt",quote=F,sep='\t')

# ----- 处理好metadata获得去重的矩阵

metadata=colnames(merged_data) %>% as_tibble() 
metadata= metadata[-1,]
colnames(metadata)='header'
# 使用separate函数，设置分隔符为第一个下划线，分割GEO的文件名
metadata <- metadata %>%
  separate(col = "header", 
           into = c("cancer", "cell"), 
           sep = "_", 
           extra = "merge",  # 只分隔第一个下划线
           fill = "left",
           remove=F) %>%   # 如果没有下划线，cell列填充NA
  mutate(clcell=gsub("RNA-Seq_","",cell)) %>%
  dplyr::select(-cell)
metadata$Datasource = ifelse(metadata$header %in% colnames(CCLE),
                                 'CCLE',
                                 ifelse(metadata$header %in% colnames(ENCODE),
                                        'ENCODE',
                                        'GEO'))

# -------- 用pancan_anno注释cell，添加 cancer istrl 信息
anno=read.csv('/cluster2/home/futing/Project/panCancer/check/meta/panCan_annometa.txt',sep='\t',check.names = F,header=F)
colnames(anno) = c('cancer','gse','cell','ucell','isctrl','istreated','ncell')
anno <- anno %>%
  dplyr::select('cancer','ucell','isctrl') %>% unique()

# 左连接合并数据
metadata_anno <- metadata %>%
  left_join(anno, by = c("clcell" = "ucell")) %>%
  mutate(
    cancer = ifelse(is.na(cancer.x), cancer.y, cancer.x)
  ) %>%
  dplyr::select(-cancer.x,-cancer.y)  # 删除临时列
# metadata_anno$clcell <- trimws(gsub("_+$|_+\\s*$", "", metadata_anno$clcell))
metadata_anno$clcell <- gsub("rep\\s*[0-9]+", "", metadata_anno$clcell, ignore.case = TRUE) #去掉所有rep字段
metadata_anno_sorted <- metadata_anno[order(metadata_anno[,1], 
                                            metadata_anno[,2], 
                                            metadata_anno[,3]), ]
write.table(metadata_anno_sorted,'/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/metadata.txt',sep="\t",quote=F,row.names = F,col.names = F)

# --------- 读入手动处理的数据
metadatan <- read.csv('/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/metadata.txt',sep='\t',check.names = F,header=F)
colnames(metadatan) <- c('header','clcell','Datasource','isctrl','cancer')
