library(GSVA)
library(readxl)
library(dplyr)
library(tibble)
library(magrittr)
library(corto)
library(limma)
library(GWAS.utils)

# 这个脚本获得subtype，并且存summary.txt文档中
# 输入是 all 矩阵和 metadata3 矩阵，在metan.R之后运行

# metadata3 data来自于 meta.R 文件

# ---- 03 scale and log | merged_data_sum to merged_data2
# 行是样本，列是基因，去掉表达量太低的样本
minRowFPKM=rowMeans(merged_data_sum)>2 # filter by mean
minNumFPKM=rowSums(merged_data_sum>0)>10 #Screen the number of samples whose expression level is not 0
merged_data2=merged_data_sum[minRowFPKM & minNumFPKM,] #联合一下
merged_data2=log2(merged_data2+1) %>% scale(merged_data2) #按照基因归一化


write.table(merged_data2,'/cluster/home/futing/Project/GBM/RNA/merge/mergedEGA_logscale.txt',sep='\t')
#write.table(merged_data2,'/cluster/home/futing/Project/GBM/RNA/merge/allmerged_logscale.txt',sep='\t')

merged_data2=read.csv('/cluster/home/futing/Project/GBM/RNA/merge/mergedEGA_logscale.txt')

write.table(data,'/cluster/home/futing/Project/GBM/RNA/merge/all.txt',sep='\t')

# ----- 04 run ssgsea
dat<- as.matrix(merged_data2)
signature_Wang2017=read_excel("geneset_pub.xlsx",sheet = "Wang2017")
signature_Neftel2019=read_excel("geneset_pub.xlsx",sheet = "Neftel2019")
signature_Richards2021=read_excel("geneset_pub.xlsx",sheet = "Richards2021")
geneset_pub=read_excel("/cluster/home/futing/Project/GBM/RNA/subtype_TPM/geneset_pub.xlsx",sheet = "Wang2017")

#ssgsea1<- gsva(dat, l,method='ssgsea')
Z<- gsva(t(dat), geneset_pub,method='ssgsea')
#Z=ssgsea(dat,l,scale = TRUE)
b=z2p(Z)


subtype=apply(Z,2,function(x) rownames(b)[which.max(x)])
subtype=rbind(Z,subtype)
subtype=t(subtype)%>% as.data.frame(.)
subtype$sample=rownames(subtype)


# subtype_expand=compare
# ----- 05 合并所有的结果

compare=merge(subtype,metadata3,by='sample') #ssgsea meta(文献+kmeans)
dim(compare[compare$subtype.x!=compare$subtype.y,])
compare=merge(clancdf,compare,by='sample') # clanc 合并
compare=merge(compare,subtype_merge,by='sample',all=T) # subtype_merge是用merged_data_sum做的

# 将新的列填充到原来的ssgea部分
compare$subtype.x[is.na(compare$subtype.x)]=compare$subtype
compare$Mesenchymal.x=ifelse(is.na(compare$Mesenchymal.x),compare$Mesenchymal.y,compare$Mesenchymal.x)
compare$Proneural.x=ifelse(is.na(compare$Proneural.x),compare$Proneural.y,compare$Proneural.x)
compare$Classical.x=ifelse(is.na(compare$Classical.x),compare$Classical.y,compare$Classical.x)
compare$id[is.na(compare$id)]=compare$sample[is.na(compare$id)]

# 合并 kmeans分型
compare=compare[,-c(12:15)]
compare1=compare1[,c(1,2,3,7,10:12,4:6,8,9)]
colnames(compare1)[c(4:5,8:10)]=c('ssgsea','litera','Mesenchymal','Proneural','Classical')


# --------- 06 比较
fil=c("H4_1","H4_2","H4_3","42MGBA_1","42MGBA_2","42MGBA_3","SW1088","U118" )
filtered_compare <- compare1 %>%
  filter((clanc == litera)& (ssgsea==litera) & (clanc==litera) & !(sample %in% fil )) #& !(sample %in% fil )) # grepl("^G", sample))
dim(filtered_compare <- summary %>%
  filter((clanc != litera) & !(sample %in% fil ) & !is.na(kmeans) & !is.na(clanc)))
dim(mid <- summary %>%
      filter(!(sample %in% fil ) & !is.na(kmeans) & !is.na(clanc)))

# hicq=merge(hic,compare,by.x='sample',by.y='id',all=T) # hic
# hicq=hicq[!is.na(hicq$sample.y),]
# list=hicq[is.na(hicq$kmeans),'sample']
# hicq$sample[is.na(hicq$kmeans)]=unlist(lapply(list, function(x) strsplit(x, 'v')[[1]][1]))


summary=  compare1[,c(1:7)] %>%
  group_by(id) %>%
  slice_min(order_by = sample) %>%
  ungroup()
table(summary[,'kmeans'])
dim(summary[grep('^G',summary$id),])
table(summary[!((summary$clanc==summary$ssgsea)&(summary$clanc==summary$litera)),'kmeans'])

write.table(summary,"/cluster/home/futing/Project/GBM/RNA/merge/summary.txt",sep="\t")
#----------- example



-log10(b)
write.table(-log10(b), "ssGESA-logp.out", col.names = TRUE, row.names = TRUE, sep="\t", quote = FALSE)
write.table(b, "ssGESA_p.out", col.names = TRUE, row.names = TRUE, sep="\t", quote = FALSE)
write.table(Z, "ssGESA_Z.out", col.names = TRUE, row.names = TRUE, sep="\t", quote = FALSE)
##########pLOT##################
library(pheatmap)
library("RColorBrewer")

pdf("Z.pdf",width=10,height=3)
hmcol <- colorRampPalette(brewer.pal(10, "RdBu"))(256)
hmcol <- hmcol[length(hmcol):1]
pheatmap(b,cellwidth=13,cellheight=15,
         col=hmcol,scale="row",
         show_colnames = T,
         cluster_rows = F,
         cluster_cols = T,
         fontsize=15)
dev.off()
pdf("Z_sort.pdf")
a=read.table("ssGESA_Z_sort.out",header=T,row.names=1)
breaksList = seq(-4, 4, by = 0.1)
cols=colorRampPalette(rev(brewer.pal(n = 7, name = "RdBu")))(length(breaksList))
pheatmap(a,color= cols, cellwidth=13,cellheight=15,breaks = breaksList, angle_col = 45,cluster_rows = FALSE,  cluster_cols = FALSE,)
dev.off()
pdf("-log_sort.pdf")
a=read.table("ssGESA-logp_sort.out",header=T,row.names=1)
breaksList = seq(0, 5, by = 0.1)
cols=colorRampPalette(rev(brewer.pal(n = 7, name = "RdBu")))(length(breaksList))
pheatmap(a,color= cols, cellwidth=13,cellheight=15,breaks = breaksList, angle_col = 45,cluster_rows = FALSE,  cluster_cols = FALSE,)
dev.off()

#########################plot PCA


library("FactoMineR")
library("factoextra")
myfpkm<-read.table("merge.allgene.tpm",header=T,comment.char="",sep = "\t",check.names=FALSE,row.names=1)
minRowFPKM=rowMeans(myfpkm)>2   # filter by mean
minNumFPKM=rowSums(myfpkm>0)>3#Screen the number of samples whose expression level is not 0
myfpkm=myfpkm[minRowFPKM & minNumFPKM,] #联合
logmyfpkm=log2(myfpkm+1)
pdf('PCA.pdf')
res.pca <- PCA(t(logmyfpkm), graph = FALSE)
fviz_pca_ind(res.pca, col.ind = "cos2", 
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
             repel = TRUE # Avoid text overlapping (slow if many points)
)