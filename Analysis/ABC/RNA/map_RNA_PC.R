setwd("/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA")
pacman::p_load(FactoMineR,ggplot2,magrittr,RColorBrewer,knitr,reshape2,extrafont,ggpubr,gridExtra,tibble)

TPM_UMAP=read.csv("/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/results/1211/TPMUMAP_1212_all.txt",sep='\t',check.names = F)
TPM_UMAP1210=read.csv("/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/results/1211/TPMUMAP_1210_all.txt",sep='\t',check.names = F)
TPM = read.csv('/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/results/TPM_1224.txt',sep='\t',check.names = F)
RNAmeta=read.csv('/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/results/RNAmeta.txt',sep='\t',check.names=F)
PCmeta=read.csv('/cluster2/home/futing/Project/panCancer/Analysis/QC/PC/PC530meta.txt',sep='\t',check.names=F)




matchmeta=merge(RNAmeta,PCmeta,by.x='clcell',by.y='ncell')
RNAmeta