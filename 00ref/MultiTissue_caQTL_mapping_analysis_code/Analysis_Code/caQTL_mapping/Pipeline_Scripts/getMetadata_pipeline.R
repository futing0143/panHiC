args = commandArgs(trailingOnly=TRUE)

#get path
path = args[1]

#get file
cpmFile = args[2]

x<-read.table(cpmFile,header=F)

y<-data.frame(x$V2,x$V3,x$V4,x$V1)

write.table(y,col=F,row=F,sep="\t",quote=F,file=paste0(path,"/",cpmFile,".metadata"))