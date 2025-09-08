quantile_normalisation <- function(df){
  df_rank <- apply(df,2,rank,ties.method="min")
  df_sorted <- data.frame(apply(df, 2, sort))
  df_mean <- apply(df_sorted, 1, mean)
  
  index_to_mean <- function(my_index, my_mean){
    return(my_mean[my_index])
  }
  
  df_final <- apply(df_rank, 2, index_to_mean, my_mean=df_mean)
  rownames(df_final) <- rownames(df)
  return(df_final)
}

args = commandArgs(trailingOnly=TRUE)

cpm=args[1]
sampleNumber=args[2]

sampleNumber=as.numeric(sampleNumber)
sampleNumber=sampleNumber+4

x<-read.table(cpm,header=T)
dim(x)
readValues <- x[,5:sampleNumber]
head(readValues)
dim(readValues)

quantNormReadValuesTPM <- quantile_normalisation(readValues)
qn_gex = apply(quantNormReadValuesTPM, 1, function(x) qqnorm(x, plot.it=FALSE)$x)

tran_qn_gex<-t(qn_gex)
write.table(tran_qn_gex,col=F,row=F,sep="\t",quote=F,file=paste0(cpm,".BW.norm.txt"))

