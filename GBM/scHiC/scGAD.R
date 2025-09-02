##https://sshen82.github.io/BandNorm/articles/scGAD-tutorial.html
library(ggplot2)
library(dplyr)
library(data.table)
library(Rtsne)
library(umap)
library(harmony)
library(BandNorm)

hic_df=read.table("/cluster/home/Kangwen/dream/stark2.0/ckw_hires.bed",row.names=NULL,header = TRUE)
summary=read.table("meta.csv",header=T)
colnames(summary)=c("id","srr","leiden","cell-type")
options(future.globals.maxSize=4000000000)
gad_score = scGAD(hic_df = hic_df, genes = hg38Annotations, depthNorm = TRUE, cores = 2, threads = 2)
summary = summary[match(colnames(gad_score), summary$srr), ]


saveRDS(gad_score,"gad_score.RDS")
write.csv(gad_score,file='/cluster/home/futing/Project/scHiC/scGAD/scGAD.csv')
###画图从这里开始
gad_score=readRDS("gad_score.RDS")

##pca
gadPCA = prcomp(gad_score)$rotation
gadPCA = data.frame(gadPCA, celltype = summary$`cell-type`)
pdf("pca.pdf")
ggplot(gadPCA, aes(x = PC1, y = PC2), group = celltype) + 
  scale_color_brewer(palette = '')+
  geom_point() + theme_bw(base_size = 20) 
dev.off()

##umap
library(umap)
iris.umap = umap::umap(t(gad_score))
summary = summary[match(rownames(iris.umap$layout), summary$cell), ]
gadumap=data.frame(iris.umap$layout, cell = summary$`cell-type cluster`)
pdf("umap_cell.pdf")
ggplot(gadumap, aes(x = X1, y = X2), col = cell) + geom_point() + theme_bw(base_size = 20) 
dev.off()

gadumap=data.frame(iris.umap$layout, datasets = summary$dataset)
pdf("umap_dataset.pdf")
ggplot(gadumap, aes(x = X1, y = X2, col = datasets)) + geom_point() + theme_bw(base_size = 20) 
dev.off()
