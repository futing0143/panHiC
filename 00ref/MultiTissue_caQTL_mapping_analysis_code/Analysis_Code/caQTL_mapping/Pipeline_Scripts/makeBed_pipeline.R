$samples
metadata="all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.noBL.txt.QTLsorted.txt.metadata"
export metadata

cpm="${cpmWithPeakInfo}.QTLsorted.txt.BW.norm.txt"
export cpm

samples="sampleList.txt"
export samples

library(data.table)
library(purrr)


args = commandArgs(trailingOnly=TRUE)

metadata=args[1]
cpm=args[2]
samples=args[3]

x<-fread(metadata)
peaks<-data.frame(x$Chr,x$Start,x$End,x$Peak)
colnames(peaks)<-c("#Chr","start","end","ID")


y<-fread(cpm)

z<-read.table(samples)
samples<-unlist(z)
samples<-as.character(samples)
colnames(y)<-samples


final<-cbind(peaks,y)

write.table(final,col.names=T,row=F,sep="\t",quote=F,file=paste0(cpm,".bed"))