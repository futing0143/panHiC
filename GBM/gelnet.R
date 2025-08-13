library(gelnet)
library(dplyr)
setwd('/cluster/home/tmp/GBM/RNA_ChIP/')

stem_ISmeta<- read.table('/cluster/home/tmp/GBM/RNA_ChIP/stem_ISmeta.txt',header=T)
stem_insulation_label<- read.table('/cluster/home/tmp/GBM/RNA_ChIP/stem_insulation_label.txt',header=T)
rownames(stem_insulation_label)<-stem_insulation_label[,1]
stem_insulation_label <- stem_insulation_label[,-1]

stemmeta<-stem_ISmeta[,'type']
names(stemmeta) = stem_ISmeta[,1]
stemmeta

# 01 preprocess
X=stem_insulation_label
m=apply(X,1,mean)
stem.norm <- X - m
stem.norm= stem.norm %>% filter(rowSums(.) != 0)
# 假设df是你的数据框
stem.norm <- stem.norm[apply(stem.norm, 1, function(x) all(x != 0)), ]
model.insul = gelnet(t(stem.norm[1:200,]),NULL,0,1)
save(model.DNA, model.RNA, file = "~/Downloads/PCBC/model-weight.rda")

#- 02 prediction using 
predict.mDNAsi <- function(met, modelPath='model-weight.rda') {
  load(modelPath)
  
  common <- intersect(names(model.DNA$w), rownames(met))
  X <- met[common, ]
  w <- model.DNA$w[common]
  
  score <- t(w) %*% X
  score <- score - min(score)
  score <- score / max(score)
}

score.meth <- predict.mDNAsi(assay(data.met), "~/Downloads/PCBC/model-weight.rda")