library(data.table)

args = commandArgs(trailingOnly=TRUE)
cpm <- args[1]

x <- fread(cpm)

pca <- prcomp(x)

write.table(pca$rotation,paste0(cpm,".pcs.txt"),col.names=T,row.names=T,quote=F,sep="\t")
