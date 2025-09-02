library(data.table)

x<-fread("all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.noBL.txt.QTLsorted.txt.BW.norm.txt")

#transpose df
x <- t(x)

pca <- princomp(x)

write.table(pca$x,"all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.noBL.txt.QTLsorted.txt.BW.norm.pcs.txt",col.names=T,row.names=T,quote=F,sep="\t")


