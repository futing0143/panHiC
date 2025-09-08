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
