library(DESeq2)
library(dplyr)
library(stringr)
library(magrittr)
library(tidyverse)

# ---- processing meta data
# rename SRR to sampleid & merge EGA GBM iPSC 
# 这个脚本的作用是合并metadata信息：sample 文献subtype kmeans srr pcaid
# 保存/cluster/home/futing/Project/GBM/RNA/merge/allmeta.txt
# May08,2025,newer version


setwd('/cluster/home/futing/Project/GBM/RNA/merge')
part1=read.csv('/cluster/home/futing/Project/GBM/RNA/merge/raw/RNA-count-matrix.txt',sep='\t')
EGA=read.csv('/cluster/home/futing/Project/GBM/RNA/sample/EGA/gene-TPM-EGA100.txt',sep='\t')
GSC=read.csv('/cluster/home/futing/Project/GBM/RNA/sample/GSE229965_all_GSCs_RNAcounts.txt',sep='\t')
all_rawanno=read.csv('/cluster/home/futing/Project/GBM/RNA/merge/legency/all_rawanno.txt',sep='\t') #原始的

meta=read.csv('/cluster/home/futing/Project/GBM/HiC/09insulation/meta_all.txt',sep='\t') # sample 和 subtype 的对应关系
srr=read.csv('/cluster/home/futing/Project/GBM/RNA/merge/meta/srr_idv2.tsv',sep='\t',header=F) #id 和 sample 的对应关系
colnames(srr)=c('srr','sample','path')
srr <- srr %>%
  group_by(sample) %>%
  mutate(sampleid = if (n() > 1) paste0(sample, "_", seq_along(sample)) else sample)  %>% 
  ungroup()


# 规范命名colnames(all_rawanno)
metadata=colnames(all_rawanno)[-c(1,152:157,161:163,177:183)]
metadata[c(129:131)]=c('42MGBA_1','42MGBA_2','42MGBA_3')
metadata=gsub("\\.2", "-2", metadata)
metadata=gsub("\\.1", "-1", metadata)

# 合并id sample subtype
metadata=data.frame(id=metadata)
metadata1=merge(metadata,srr,by.x='id',by.y='sampleid',all=T)
colnames(metadata1)=c('sample','srr','id','path')
metadata1$id=ifelse(is.na(metadata1$id),metadata1$sample,metadata1$id) #用sample列填充id
metadata2=merge(metadata1,meta,by.x='id',by.y='sample',all=T)

# 规范EGA的命名Pxx.SFxxv-x
metadata2$ega <- paste0(
  sapply(strsplit(metadata2$id, ".SF"), function(x) x[1]), "_", 
  sapply(strsplit(metadata2$id, "v"), function(x) x[2])
)
#EGA是Pxx-x的格式，ega列为拼接后字符串
EGA=read.csv('/cluster/home/futing/Project/GBM/HiC/09insulation/EGA.txt',sep='\t',header=F)
metadata2$ega <- sapply(strsplit(metadata2$ega, "-"), function(x) x[1]) #去掉最后的-
metadata2$ega <- ifelse(startsWith(metadata2$ega, "P"), metadata2$ega, NA) #只保留P开头的

# 合并EGA的RNA分型，填充前几个样本的RNA分型
metadata3=merge(metadata2,EGA,by.x='ega',by.y='V1',all=T)
metadata3$subtype=ifelse(is.na(metadata3$subtype),metadata3$V3,metadata3$subtype)#借EGA V3的亚型信息填充subtype列
metadata3=metadata3[!is.na(metadata3$sample),]#去掉GB GSC3 astro 这些hic样本,sample是RNA的id
metadata3=metadata3[,-c(1,8,9)]

# 对照组的subtype
metadata3$subtype=ifelse(metadata3$id=='pHGG','pHGG',
                         ifelse(metadata3$id=='NHA','NHA',
                                ifelse(metadata3$id =='iPSC','iPSC',
                                       ifelse(metadata3$id=='NPC','NPC',metadata3$subtype))))
# pc1 界定的 kmeans 分类
hic=read.csv('/cluster/home/futing/Project/GBM/HiC/09insulation/00plot/PC1/scatter/pc1_pca.csv',row.names = NULL) 
hic=hic[,c(2,67)]
metadata3=merge(metadata3,hic,by.x='id',by.y='sample',all=T)
metadata3$dataset <- ifelse(grepl("^P", metadata3$id), "Mathur et al", metadata3$dataset)

# 那些需要合并的列
list=metadata3$id[is.na(metadata3$sample)]
list=list[5:11]
# metadata3 <- metadata3 %>% drop_na(sample)
metadata3 <- metadata3 %>% filter(!id %in% c('A172_2','G523','G567','G583'))

write.table(metadata3,'/cluster/home/futing/Project/GBM/RNA/merge/allmeta.txt',sep='\t',row.names = F)
metadata3=read.csv('/cluster/home/futing/Project/GBM/RNA/merge/allmeta.txt',sep='\t')


#----------------------------------------------
#--- 按照metadata 处理 rsem 输出矩阵
# --------------------------------------------
all_rawanno=read.csv('/cluster/home/futing/Project/GBM/RNA/merge/legency/all_anno.txt',sep='\t') #原始的

# -------- 00 处理data，对应colnames
data <- all_rawanno[-c(1,152:157,161:163,177:183)]
colnames(data)[c(129:131)]=c('42MGBA_1','42MGBA_2','42MGBA_3')
rownames(data)=data$ENTREZ
# all_anno
data <- all_rawanno
colnames(data)[c(101:103)]=c('42MGBA_1','42MGBA_2','42MGBA_3')
colnames(data)=gsub("\\.2", "-2", colnames(data))
colnames(data)=gsub("\\.1", "-1", colnames(data))
data=data[,match(metadata3$sample,colnames(data))]

load('/cluster/home/futing/pipeline/RNA/ref/geneinfo_human.RData')
exclude_list=metadata3[(metadata3$subtype %in% c('pHGG','iPSC','NPC','NHA')),'sample']
merged_data=data[,!(colnames(data) %in% exclude_list) ]

# ----- 01 合并基因 ｜ qc merged_data to merged_data1
library(tidyverse)

merged_data_clean <- merged_data %>%
  # 1. 将行名转为列，并合并qc数据
  rownames_to_column(var = "ensembl_gene_id") %>%
  left_join(qc %>% select(ensembl_gene_id, raw), by = "ensembl_gene_id") %>%
  
  # 2. 清理并转换数值列（排除raw列）
  mutate(across(
    .cols = c(-ensembl_gene_id, -raw),  # 明确排除非数值列
    .fns = ~ as.numeric(stringr::str_trim(.))
  )) %>%
  
  # 3. 按gene_id聚合（确保只对数值列求和）
  group_by(gene_id = raw) %>%
  summarise(across(
    .cols = where(is.numeric),  # 只对数值列求和
    .fns = sum,
    na.rm = TRUE
  )) %>%
  
  # 4. 处理结果
  filter(!is.na(gene_id)) %>%  # 移除NA分组
  column_to_rownames("gene_id") %>%
  t() %>%
  as.data.frame() %>%
  replace(is.na(.), 0)


# ----- 02 合并 sample | merged_data1 to merged_data_sum
# 合并特定的样本 P开头、采样位置不明确的HiC样本
# metadata3$sample 为NA是那些没有合并的EGA样本，因为srr矩阵中没有他们的信息
list=metadata3$id[is.na(metadata3$sample) & !(metadata3$id %in% c('A172_2','G583','G567','G523'))]

merged_data1$id <- ifelse(
  grepl("^P", rownames(merged_data1)),
  sapply(strsplit(rownames(merged_data1), 'v'), function(x) ifelse(length(x) >= 1, x[1], NA)),
  rownames(merged_data1)
) # 去掉 v 之后的

merged_data1$id <- ifelse(
  merged_data1$id %in% list,
  merged_data1$id,
  rownames(merged_data1)
) #选择 list 中的样本，保留分组变量id，其他改为原来的sample名

merged_data1$id = sapply(strsplit(merged_data1$id,"_"),`[`,1) # 去掉 sample_number 的 '_n' 部分

merged_data_sum= aggregate(x=merged_data1[,1:(ncol(merged_data1)-1)],
                           by=list(sample=merged_data1$id),
                           FUN=sum) %>%
  column_to_rownames(var='sample')
write.table(merged_data_sum,"/cluster/home/futing/Project/GBM/RNA/merge/merged_RNA.txt",sep="\t")

