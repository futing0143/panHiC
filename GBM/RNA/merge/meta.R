library(DESeq2)
library(dplyr)
library(stringr)

# old version of processing metadata
# 这个脚本的作用是合并metadata信息：sample 文献subtype kmeans srr 
# 保存/cluster/home/futing/Project/GBM/RNA/merge/allmeta.txt

setwd('/cluster/home/futing/Project/GBM/RNA/merge')
all_raw=read.csv('/cluster/home/futing/Project/GBM/RNA/merge/TPM/all_raw.txt',sep='\t') #所有的
all_log=read.csv('/cluster/home/futing/Project/GBM/RNA/merge/all_logscale.txt',sep='\t') # 所有的 log
all_rawanno=read.csv('/cluster/home/futing/Project/GBM/RNA/merge/TPM/all_rawanno.txt',sep='\t') #原始的
all_merged=read.csv('/cluster/home/futing/Project/GBM/RNA/merge/TPM/mergedEGA_logscale.txt',sep='\t') # EGA合并，cell_line不合并
merged_RNA=read.csv('/cluster/home/futing/Project/GBM/RNA/merge/merged_RNA.txt',sep='\t') # 全合并

meta=read.csv('/cluster/home/futing/Project/GBM/HiC/09insulation/meta_all.txt',sep='\t') # sample 和 subtype 的对应关系
other=read.csv('/cluster/home/futing/Project/GBM/RNA/merge/meta/srr_id.tsv',sep='\t') #id 和 sample 的对应关系
#other=other[-c(32,43:47),-3]
#other$sample[30:31]=c('SW1088','U118')

# 规范命名colnames(all_rawanno)
metadata=colnames(all_rawanno)[-c(1,152:157,161:163,177:183)]
metadata[c(129:131)]=c('42MGBA_1','42MGBA_2','42MGBA_3')
metadata=gsub("\\.2", "-2", metadata)
metadata=gsub("\\.1", "-1", metadata)

# 合并id sample subtype
metadata=data.frame(sample=metadata)
metadata1=merge(metadata,other,by='sample',all=T)
metadata1$id=ifelse(is.na(metadata1$id),metadata1$sample,metadata1$id)
metadata2=merge(metadata1,meta,by.x='id',by.y='sample',all=T)

# 规范EGA的命名Pxx.SFxxv-x
metadata2$ega <- paste0(
  sapply(strsplit(metadata2$id, ".SF"), function(x) x[1]), "_", 
  sapply(strsplit(metadata2$id, "v"), function(x) x[2])
)
#EGA是Pxx-x的格式，ega列为拼接后字符串
EGA=read.csv('/cluster/home/futing/Project/GBM/HiC/09insulation/EGA.txt',sep='\t',header=F)
metadata2$ega <- sapply(strsplit(metadata2$ega, "-"), function(x) x[1])
metadata2$ega <- ifelse(startsWith(metadata2$ega, "P"), metadata2$ega, NA)
# 合并EGA的RNA分型，填充前几个样本的RNA分型
metadata3=merge(metadata2,EGA,by.x='ega',by.y='V1',all=T)
metadata3$subtype=ifelse(is.na(metadata3$subtype),metadata3$V3,metadata3$subtype)#借EGA的信息填充subtype列
metadata3=metadata3[!is.na(metadata3$sample),]#去掉GB GSC3 astro 这些hic样本
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


list=metadata3$id[is.na(metadata3$sample)]
list=list[5:11]
write.table(metadata3,'/cluster/home/futing/Project/GBM/RNA/merge/allmeta.txt',sep='\t',row.names = F)
metadata3=read.csv('/cluster/home/futing/Project/GBM/RNA/merge/allmeta.txt',sep='\t')