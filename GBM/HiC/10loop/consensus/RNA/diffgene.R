library(DESeq2)
library(dplyr)
library(stringr)


#-------------- example data -----------
#data <- round(as.matrix(data)) %>% as.data.frame(.)
###
condition <- factor(c(rep('Virgin',3),rep('d6.5',3),rep('d8.5',3),rep('d11.5',3)),levels=c('Virgin','d6.5','d8.5','d11.5'))
colData <- data.frame(row.names=colnames(data), condition)

dds <- DESeqDataSetFromMatrix(data, colData, design= ~ condition)
dds <- DESeq(dds)

##################查看结果的名称，本次实验中是 "Intercept" "condition_d6.5_vs_d0"  "condition_d8.5_vs_d0"  "condition_d11.5_vs_d0"
resultsNames(dds)
# "Intercept"  "condition_d6.5_vs_d0"  "condition_d8.5_vs_d0"  "condition_d11.5_vs_d0"

##################将结果用results()函数来获取，赋值给res变量
res <- results(dds,name="condition_d11.5_vs_Virgin")
# summary一下，看一下结果的概要信息
summary(res)
# out of 4520 with nonzero total read count
# adjusted p-value < 0.1
# LFC > 0 (up)       : 195, 4.3%
# LFC < 0 (down)     : 157, 3.5%
# outliers [1]       : 3, 0.066%
# low counts [2]     : 2629, 58%
# (mean count < 1)
# [1] see 'cooksCutoff' argument of ?results
# [2] see 'independentFiltering' argument of ?results
table(res$padj<0.05)
# FALSE  TRUE 
#  1610 278 
res <- res[order(res$padj),]
# 获取差异基因
resSig <- res[which(res$pval < 0.05 & abs(res$log2FoldChange) > 1),]
resSig[which(resSig$log2FoldChange > 0), "up_down"] <- "Up"
resSig[which(resSig$log2FoldChange < 0), "up_down"] <- "Down"


###-------- get all the result
###--- estimateSizeFactors() 用于估计每个样本的大小因子（size factors），这些大小因子用来校正测序深度或样本间的总RNA含量的差异
dds <- estimateSizeFactors(dds)
###---counts(dds, normalize=TRUE)
###---经过大小因子调整的计数,这有助于纠正不同样本间的测序深度差异
resdata <-  merge(as.data.frame(res),as.data.frame(counts(dds,normalize=TRUE)),by="row.names",sort=FALSE)
###---经过正则化对数转换的数据，适合用于数据可视化和某些统计分析
norm_data_rna <- assay(rlogTransformation(dds))


###------------------------------------ Batch DeSeq2 Differences -----------------------------------------------###
group_list=c("Virgin","d6.5","d8.5","d11.5") #就是分成多少组

num=c(3,3,3,3) #这几组每组分别有多少个

#res_lfc的数据在new_ma
Batch_Deseq_differnece<-function(exprSet,group,num,save_dir="Alldiffenece",save_dir2="NEW_MA"){
  ##create a folder 
  save_dir<-paste0(save_dir,"/")
  dir.create(save_dir)
  save_dir2=paste0(save_dir2,"/")
  dir.create(save_dir2)
  ## creat coldata
  group_list= factor(rep(group,num))
  colData=data.frame(row.names = colnames(exprSet),group=group_list)
  
  ##每个元素与其他比较
  for (i in 1:length(group)){
    name=unique(group)[i]
    print(name)
    ###以 name 为标准进行比较
    colData$group<-relevel(colData$group,ref=name)
    dds=DESeq2::DESeqDataSetFromMatrix(countData = exprSet,
                                       colData = colData,
                                       design = ~group)
    ##只保留count >10的基因
    dds <- dds[ rowSums(DESeq2::counts(dds)) > 10, ]
    dds <- DESeq2::DESeq(dds)
    for (j in 2:length(DESeq2::resultsNames(dds))){
      resname=DESeq2::resultsNames(dds)[j]
      res=DESeq2::results(dds, name=resname)#res
      res_lfc <- lfcShrink(dds, coef=j, res=res, type="apeglm")#res_lfc
      ## result overview
      summary(res_lfc)
      summary(res)
      ## save the result
      write.csv(res,paste0(save_dir,resname,".csv"))
      save_dir_MA=paste0(save_dir2,"/",resname)
      dir.create(save_dir_MA)
      write.csv(res,paste0(save_dir_MA,"/",resname,"_res.csv"))
      write.csv(res_lfc,paste0(save_dir_MA,"/",resname,"_reslfc.csv"))
      ## 绘图
      png(paste0(save_dir_MA,"/",resname,"_MA.png"),width=600*3,height=3*600,res=72*3) 
      plotMA(res, ylim=c(-3,3),main=paste0(resname," MA"))
      dev.off()
      png(paste0(save_dir_MA,"/",resname,"_MAlfc.png"),width=600*3,height=3*600,res=72*3) 
      xlim <- c(1,1e5); ylim<-c(-3,3)
      plotMA( res_lfc, xlim=xlim, ylim=ylim, main=paste0(resname," apeglm"))
      dev.off()
    }
  }
}

Batch_Deseq_differnece(exprSet=count_en,group=group_list,num,save_dir = "New_en",save_dir2="NEW_MA_en")


####------------ saving sigificant gene count ---------###
setwd('/Users/joanna/Documents/02.Project/胎盘NK/New/')

for (n in 2:4){
  i = group_list[n]
  pattern_string <- paste0("group_Virgin_vs_", i, ".csv")
  print(pattern_string)
  vir <- read.csv(list.files(pattern=pattern_string ))
  vir <- vir[which(vir$pval < 0.05 & abs(vir$log2FoldChange) > 1),]
  res_sig <- TPM_bio[which(rownames(TPM_bio) %in% vir$X),]
  res_sig <- apply(res_sig[,c(1:3,(n*3-2):(n*3))],1,function(x){log2(x+1)}) %>% as.data.frame(.) %>% t(.)
  write.csv(res_sig,paste0('Virgin_',i,'.csv'))
}
