args = commandArgs(trailingOnly=TRUE)

i=args[1]
path=args[2]

x<-read.table(paste0("/path/to/cpm_peakInfo.txt"),header=T)
y<-read.table(paste0(path,"/cluster",i,"/cluster",i,"_CPM_average_noBL.txt"),header=T)

z<-cbind(x,y)

write.table(z,paste0(path,"/cluster",i,"/cluster",i,"_CPM_average_noBL.withPeakInfo.txt"),row.names=FALSE,col.names=TRUE, sep="\t", quote = FALSE)
