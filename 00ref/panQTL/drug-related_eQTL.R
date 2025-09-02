library(data.table)
library(ggplot2)
library(dplyr)

args <- commandArgs(trailingOnly = T)
#args=c("THCA", "cancerRxTissue")
ctype=args[1]
source=args[2]


## match samples ##############################################################

##### files ##########
cov_file=paste0("exp_cov/",args[1],".cov")
geno_file=paste0("geno/",args[1],".geno")


###cov ###
cov=fread(cov_file,header = T)
colnames(cov)[1]="ID"

##eQTLs##
eQTL_file=paste0(args[1],".eQTLs.txt")

if (!file.exists(eQTL_file)) {
cmd=paste0("cat PancanQTLv1/cis_eQTLs_all_re PancanQTLv1/trans_eQTLs_all_re |awk ' NR==1 || $1== \"",args[1],"\"' > ",eQTL_file)
system(cmd)
}

eQTL=fread(eQTL_file,head=T)
rs=unique(eQTL$rs)

##Geno #########
geno=fread(geno_file,head=T)
colnames(geno)[1]="ID"

#filter rs
geno$ID=stringr::str_split(geno$ID,":",simplify = T)[,1]
geno=subset(geno,ID %in% rs)


## drug response #########
if(source=="DrVAEN"){
dr_file="drug_source/VAEN_GDSC.A.pred_TCGA.rename.txt"
DR=fread(dr_file,head=T,sep="\t")
DR=dplyr::filter(DR,Cancer==args[1])
DR=dplyr::select(DR,-Cancer)
colnames(DR)=gsub("\\/","_",colnames(DR))
}else if(source=="cancerRxTissue"){
  dr_file="drug_source/cancerRxTissue.GDSC.rename.clean.txt"
  DR=fread(dr_file,head=T,sep="\t")
  DR=dplyr::filter(DR,Cancer==args[1])
  DR$Cancer=NULL
}
  
DR=na.omit(DR)
DR=t(DR)
colnames(DR)=DR[1,]
DR=DR[-1,]
colnames(DR)=gsub("\\-\\d+$","",perl = T,colnames(DR))
colnames(DR)=gsub("-",".",perl = T,colnames(DR))
DR=as.data.frame(DR)
DR$ID=rownames(DR)


#overlap sample
ov=intersect(colnames(cov),colnames(DR))
ov=intersect(colnames(geno),ov)

geno=select(geno,ov)
cov=select(cov,ov)
DR=select(DR,ov)
exp=DR


exclude_cov <- apply(cov, 1, sd, na.rm = TRUE) != 0
cov = cov[exclude_cov,]

#rm the peer co-factors
cov=cov[!grepl("peer", cov$ID, ignore.case = TRUE), ]


## write file for MatrixEQTL #######
input_folder <- paste0(source,"_input/")
if (!file.exists(input_folder)) {
  dir.create(input_folder)
}

geno_out=paste0(input_folder,args[1],".",source,".drug.geno.txt")
cov_out=paste0(input_folder,args[1],".",source,".drug.cov.txt")
DR_out=paste0(input_folder,args[1],".",source,".drug.exp.txt")

fwrite(geno,geno_out,col.names = T,row.names = F,sep="\t",quote = F,na = "NA")
fwrite(cov,cov_out,col.names = T,row.names = F,sep="\t",quote = F,na = "NA")
fwrite(DR,DR_out,col.names = T,row.names = F,sep="\t",quote = F,na = "NA")

################################################################################
library(MatrixEQTL)
Cond=args[1]
# Genotype file name
SNP_file_name = geno_out
# Gene expression file name
expression_file_name = DR_out
# Covariates file name
covariates_file_name = cov_out

# Output file name
output_file_name_tra = paste(Cond,".",source,".drugQTL.xls",sep="")

# Only associations significant at this level will be saved
pvOutputThreshold_tra = 1;
# Set to numeric() for identity.
errorCovariance = numeric();

## Load genotype data
snps = SlicedData$new();
snps$fileDelimiter = "\t";      # the TAB character
snps$fileOmitCharacters = "NA"; # denote missing values;
snps$fileSkipRows = 1;          # one row of column labels
snps$fileSkipColumns = 1;       # one column of row labels
snps$fileSliceSize = 2000;      # read file in slices of 2,000 rows
snps$LoadFile(SNP_file_name);

## Load gene expression data
gene = SlicedData$new();
gene$fileDelimiter = "\t";      # the TAB character
gene$fileOmitCharacters = "NA"; # denote missing values;
gene$fileSkipRows = 1;          # one row of column labels
gene$fileSkipColumns = 1;       # one column of row labels
gene$fileSliceSize = 2000;      # read file in slices of 2,000 rows
gene$LoadFile(expression_file_name);

## Load covariates
cvrt = SlicedData$new()
cvrt$fileDelimiter = "\t"      # the TAB character
cvrt$fileOmitCharacters = "NA" # denote missing values;
cvrt$fileSkipRows = 1          # one row of column labels
cvrt$fileSkipColumns = 1 
cvrt$LoadFile(covariates_file_name)

#Linear model to use, modelANOVA, modelLINEAR, or modelLINEAR_CROSS
useModel = modelLINEAR; # modelANOVA, modelLINEAR, or modelLINEAR_CROSS

##### run trans eQTL without FDR #######
Matrix_eQTL_main(
  snps = snps,
  gene = gene,
  cvrt = cvrt,
  output_file_name     = output_file_name_tra,
  pvOutputThreshold     = 1, # 0 means cancel trans eQTL analysis
  useModel = useModel,
  errorCovariance = errorCovariance,
  verbose = TRUE,
  #output_file_name.cis = output_file_name_cis,
  pvOutputThreshold.cis = 0, # 0 means cancel cis eQTL analysis
  #snpspos = snpspos,
 # genepos = genepos,
 # cisDist = cisDist,
  pvalue.hist = "qqplot",
  min.pv.by.genesnp = FALSE,
  noFDRsaveMemory = T)

#################
output_file_name_tra_fdr = paste(Cond,".",source,".drugQTL.all.xls",sep="")

result=fread(output_file_name_tra,head=T,sep="\t")
result$SE=as.numeric(result$beta)/as.numeric(result$`t-stat`)

#calculated the FDR in each gene and drug
result=split(result, result$gene)

calculate_FDR <- function(x) {
  x$FDR <- p.adjust(as.numeric(x$`p-value`), method = "fdr")
  return(x)
}

result=lapply(result, calculate_FDR)
result=bind_rows(result)


colnames(eQTL)[2]="SNP"
cat=left_join(eQTL,result,by="SNP")

cat=transmute(cat,
              cancer_type,
              SNP,
              chr,
              position,
              alleles,
              gene=gene.x,
              drug=gene.y,
             Beta=beta.y,
             SE,
             P_value=`p-value`,
             FDR
)

result=dplyr::filter(cat,FDR<0.05)
result$source=source


#####################################################
# boxplot
#fig
pp<-function(snp,gene,source,x,y,p){
  
  
  if(length(x)>0 & length(y)>0){
    
    colnames(y)=colnames(x)
    data=t(rbind(x,y))
    p=ifelse(p < 0.001, formatC(p, format = "e", digits = 2), formatC(p, digits = 3))
    data=na.omit(data)
    mode(data)="numeric"
    G0 <- as.vector(as.numeric(t(data[data[,1]==0,2])))
    G1 <- as.vector(as.numeric(t(data[data[,1]==1,2])))
    G2 <- as.vector(as.numeric(t(data[data[,1]==2,2])))
    
    minvalue <- as.vector(min(data[,2]))
    maxvalue <- as.vector(max(data[,2]))
    
    par(mar=c(5,5,3,1))
    boxplot(G0, at =1, xlim =c(0.5, 3.5),
            ylim=c(minvalue, maxvalue), 
            outline=F, 
            ylab =paste0(gene,"\n(",source,")"), 
            col="#FF7878")
    tmp <- G0
    tmp2 <- jitter(rep(1, length(tmp)), factor =5)
    points(tmp2, tmp, pch =20, cex = 1,col="red")
    
    boxplot(G1, at =2, outline=F, add=TRUE, col ="#8F8FFF")
    tmp <- G1
    tmp2 <- jitter(rep(1, length(tmp)), factor =5)
    points((tmp2+1), tmp, pch =20, cex =1,col="#0000F6")
    
    boxplot(G2, at =3, outline=F, add=TRUE, col ="#FFD17D")
    tmp <- G2
    tmp2 <- jitter(rep(1, length(tmp)), factor =5)
    points((tmp2+2), tmp, pch =20, cex =1,col="#ED7D31")
    
    title(main = paste(Cond,gene,snp,sep=", "))
    axis(side=1, at=c(1:3), c("AA","Aa","aa"))
    mtext(side = 1,at=1, paste("(n=", length(G0), ")", sep = ""), line =2, cex=1, las=1)
    mtext(side = 1,at=2, paste("(n=", length(G1), ")", sep = ""), line =2, cex=1, las=1)
    mtext(side = 1,at=3, paste("(n=", length(G2), ")", sep = ""), line =2, cex=    1, las=1)
    mtext(side = 1,at=2,  paste0("n = ",length(G0)+length(G1)+length(G2),", p = ",p ),line =3.5, cex=1, las=1)
  }
}

#png dir
fig_folder <- "figure"
if (!file.exists(fig_folder)) {
  dir.create(fig_folder)
}
fig_folder <- "figure/drugQTL/"
if (!file.exists(fig_folder)) {
  dir.create(fig_folder)
}


#################

out=data.frame()

for (i in 1:nrow(result)){
  r=result[i,]
  r$Plot=paste0("figure/drugQTL/",r$cancer_type,".",r$SNP,".",r$drug,".",r$source,".drugQTL.png")
  g=subset(geno,ID==r$SNP)[,-1]
  e=subset(exp,ID==r$drug)[,-1]
  
  if(nrow(g)<1 | nrow(e)<1){
    print(paste0(r$SNP," ",r$drug," ",r$source," is missing"))
    next()}
  
  png(r$Plot,width =1800, height = 1800, res = 300)
  pp(r$SNP,r$drug,r$source,g,e,r$P_value)
  dev.off()
  
  if (!file.exists(r$Plot)) {
    print(r$Plot)
  } 
  
  out=rbind(out,r)
  
}

out=unique(out) %>%
  arrange(chr,position) 

out_file=paste0(ctype,".",source,".drug-eQTL.xls")
fwrite(out,out_file,col.names = T,row.names = F,sep="\t",na = "NA",quote = F)
