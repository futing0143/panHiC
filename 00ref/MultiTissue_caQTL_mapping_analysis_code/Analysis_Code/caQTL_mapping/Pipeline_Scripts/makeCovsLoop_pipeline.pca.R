args = commandArgs(trailingOnly=TRUE)

pcNum=args[1]
pcaFile=args[2]
sampleNumber=args[3]
plinkFile=args[4]
path=args[5]
cpm=args[6]



#read in peer pcs
pca <- read.table("/project/voight_viz/bwenz/tensorQTL/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.noBL.txt.QTLsorted.txt.BW.norm.pcs.txt",header=T)

#only want first x peer factors
pca<-pca[0:sampleNumber,0:pcNum]
dim(pca)

genPC <- read.table(plinkFile)

#grab first 3 genotype PCs
genPC<-genPC[,3:5]
 
dim(genPC)


#combine PEER + genotype PCs
finalCovariatesMatrix <- cbind(genPC,pca)
head(finalCovariatesMatrix)

#transpose
finalCovariatesMatrix <- t(finalCovariatesMatrix)
dim(finalCovariatesMatrix)

z<-read.table("sampleList.txt")
samples<-unlist(z)
samples<-as.character(samples)
length(samples)
finalCovariatesMatrix<-rbind(samples,finalCovariatesMatrix)
colnames(finalCovariatesMatrix)<-samples

if (pcNum == 0){
    rownames(finalCovariatesMatrix)<-c("id","PC1","PC2","PC3")
    print("here1")
} else {
    rownames(finalCovariatesMatrix)<-c("id","PC1","PC2","PC3",paste0("pca_",1:pcNum))
    print("here2")
}

#write to output
write.table(finalCovariatesMatrix,paste0(path,"/prinComp_",pcNum,"/",cpm,".pca",pcNum,".covs.fastQTL.txt"),col.names=F,row=T,sep="\t",quote=F)

