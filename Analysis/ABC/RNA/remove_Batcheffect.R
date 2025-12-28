pacman::p_load(biomaRt,GenomicFeatures,tidyverse,dplyr,purrr,sva)
library("FactoMineR")
library("factoextra")

setwd('/Users/joanna/Documents/02.Project/GBM/05code/RNA')
load('/Users/joanna/Documents/02.Project/GBM/05code/RNA/TPM1211.RData')
#--- input data: 来自Mergeall.R
data=t(df_filtered)
edata=log(data+1) %>% as_tibble()
meta=read.table('/Users/joanna/Documents/02.Project/GBM/05code/RNA/RNAmeta.txt',sep='\t',header=T)
SampleInfo <- meta[match(colnames(edata), meta$header), ]
colnames(SampleInfo)[1] <- 'sample_name'
# -------------- 
# parametric adjustment
combat_edata1 = ComBat(dat=edata, batch=batch, mod=NULL, par.prior=TRUE, prior.plots=FALSE)
# non-parametric adjustment, mean-only version
combat_edata2 = ComBat(dat=edata, batch=batch, mod=NULL, par.prior=FALSE, mean.only=TRUE)
# reference-batch version, with covariates
combat_edata3 = ComBat(dat=edata, batch=batch, mod=mod, par.prior=TRUE, ref.batch=3)

expr_combat <- ComBat(dat = edata, batch = SampleInfo$Datasource)
# 查看去除批次后的数据
expr_combat[1:4,1:4]
expr_combat <- as.data.frame(expr_combat)
#p1 <- PCA.plot(expr_combat,factor(Sample_infor$Sample_origination))
#p1 <- PCA.plot(expr_combat,factor(Sample_infor$Group))
PCA.plot = function(dat,col){
  df.pca <- PCA(t(dat), graph = FALSE)
  fviz_pca_ind(df.pca,
               geom.ind = "point",
               col.ind = col ,
               addEllipses = TRUE,
               legend.title = "Groups")
}
p1 <-PCA.plot(edata,paste0(SampleInfo$Datasource))
p2 <- PCA.plot(expr_combat,paste0(SampleInfo$Datasource))
p2+p1

# ===================== method 2

# include condition (group variable)
adjusted_counts <- ComBat_seq(count_matrix, batch=batch, group=group, full_mod=TRUE)

# do not include condition
adjusted_counts <- ComBat_seq(count_matrix, batch=batch, group=NULL, full_mod=FALSE)