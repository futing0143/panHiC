# getFeatureZeroStats.R

library(data.table)

x<-fread("all_samples_peak_by_sample_matrix_CPM_genrich_10.19.22.txt.gz",header=T)
peaks<-data.frame(x$Peak)
x<-x[,5:10301]

zeroes=rowSums(x==0)


write.table(zeroes,"all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.noAverage.featureZeroCounts.txt",col=T,row=F,sep="\t",quote=F)

zeroFinal<-cbind(peaks,zeroes)

write.table(zeroFinal,"all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.noAverage.featureZeroCountsWithFeatInfo.txt",col=T,row=F,sep="\t",quote=F)