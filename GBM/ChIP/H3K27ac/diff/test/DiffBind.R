#安装 ----
if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
#BiocManager::install("ChIPseeker")
setwd("/cluster/home/futing/Project/GBM/ChIP/H3K27ac/diff")

#DiffBind ----
BiocManager::install("ensembldb",force = TRUE)
BiocManager::install("GenomeInfoDb")
BiocManager::install("ensembldb")

#导入包 ----
library(tidyverse)
library(ChIPQC)
library(clusterProfiler)
library(GenomicRanges)
library(BSgenome.Hsapiens.UCSC.hg38)
library(GreyListChIP)
library(profileplyr)
library(readxl)
library(DiffBind)
library(ChIPseeker)
library(GenomeInfoDb)
library(TxDb.Hsapiens.UCSC.hg38.knownGene)
library(ggplot2)
library(ggupset)
library(ggplotify)
library(EnsDb.Hsapiens.v86)
library(org.Hs.eg.db)
library(AnnotationDbi)
library(ChIPpeakAnno)
library(BiocParallel)
library(GenomicRanges)


##------------------------------------------------------------------------------
## SECTION 1: PART 1 - INITIAL ANALYSIS
##------------------------------------------------------------------------------

#读入文件 ----
meta_chip=read_excel("chip.xlsx")
write.csv(meta_chip, "meta_chip.csv", row.names = FALSE,quote = F)
# write.table(meta_chip,"meta_chip.txt")

# --- 01 创建 DiffBind 对象进行PCA分析 ----
###确保文件都有值，不然会报错
dbObj <- dba(sampleSheet = "test/test.csv",peakFormat="narrow")
###存储的是原始peaks数据，没有通过reads数进行校正
save(dbObj,file="dbObjoriginal.data")
dba.plotPCA(dbObj, label=DBA_CONDITION) 

# 根据原始peaks数据(peak caller score)绘制样本间相关性热图，并存储为PDF ----
pdf("Figure1_Correlationheatmap.pdf")
plot(dbObj)
dev.off()

# --- 02 计算 Reads 并保存 ----
# 根据bam文件中reads数进行校正，这时候要读取bam文件，花费较多时间和内存。样本数越多，所需时间和内存就越多
# 计算每个peaks/regions的count信息。先对一致性的peaks数据集进行标准化
# 然后根据他们的峰值（point of greatest read overlap）再次中心化并修剪一些peaks，最终得到更加标准的peak间隔。
# 使用函数dba.count()，参数bUseSummarizeOverlaps可以得到更加标准的计算流程

dbObj <- dba.count(dbObj,bParallel = FALSE,bUseSummarizeOverlaps=TRUE)
dba.plotPCA(dbObj,  attributes=DBA_FACTOR, label=DBA_ID)
save(dbObj,file="dbObjcount.data")

# 根据原校正后peaks数据(affinity scores)绘制样本间相关性热图，并存储为PDF
pdf("Figure2_Correlationheatmap.pdf")
plot(dbObj)
dev.off()


# --- 03 计算库大小信息
info <- dba.show(dbObj)
libsizes <- cbind(LibReads=info$Reads, FRiP=info$FRiP,PeakReads=round(info$Reads*info$FRiP)) 
rownames(libsizes) <- info$ID
save(libsizes,file="libsizes.data")


# --- 04 对数据根据reads数进行标准化，然后储存
dbObj <- dba.normalize(dbObj,normalize=DBA_NORM_LIB)
norm <- dba.normalize(dbObj, bRetrieve=TRUE)
dba.plotPCA(dbObj, label=DBA_CONDITION) 

normlibs <- cbind(FullLibSize=norm$lib.sizes,
                  NormFacs=norm$norm.factors,
                  NormLibSize=round(norm$lib.sizes/norm$norm.factors))
rownames(normlibs) <- info$ID
normlibs
save(norm,file="norm.data")
save(normlibs,file="normlibs.data") 
save(dbObj,file="dbObjnormlized.data")

###正式开始 ----
load("dbObjoriginal.data")
pdf("plotPCA.pdf")
dba.plotPCA(dbObj, label=DBA_REPLICATE) 
dev.off()
load("dbObjcount.data")
dba.plotPCA(dbObj, label=DBA_CONDITION) 
load("libsizes.data")
load("norm.data")
load("normlibs.data")
load("dbObjnormlized.data")
dba.plotPCA(dbObj, label=DBA_CONDITION) 
dba.plotPCA(dbObj, label=DBA_REPLICATE) 
#####先看一下重复间共有和特有peaks，最多也就做4个样品的venn图了，再多就报错了
#pdf("Figure 3 peaks among replicats.pdf")
#dba.plotVenn(dbObj,dbObj$masks$DGC)
#dba.plotVenn(dbObj,dbObj$masks$GSC)
#dev.off()


# --- 04 差异分析
# 构建contrast，即差异分析分组，这直接关系到后边所有作图数据，所以这一步极其关键
dbObj <- dba.contrast(dbObj, minMembers=2,block=DBA_REPLICATE)
dbObj <- dba.contrast(dbObj, minMembers=2,categories = DBA_CONDITION)
#dbObj

# 差异分析
###黑名单是encode定义的，灰名单是根据input,如果没有input，就会报错
dbObj <- dba.analyze(dbObj,method=DBA_ALL_METHODS, bGreylist=FALSE)
save(dbObj,file="dbObana.data")
dba.show(dbObj, bContrasts=TRUE)

# 差异分析报告
comp1.edgR<- dba.report(dbObj, method=DBA_EDGER, contrast = 1 ) 
comp1.deseq2<- dba.report(dbObj, method=DBA_DESEQ2, contrast = 1) 
head(comp1.deseq2)

# 筛选 FDR < 0.05 的显著 peak 并输出 BED
out <- as.data.frame(comp1.edgR)
edge.bed <- out[ which(out$FDR < 0.05), 
                 c("seqnames", "start", "end", "strand", "Fold")]
write.table(edge.bed, file="GSC_vs_DGC_edgeR_sig.bed", sep="\t", quote=F, row.names=F, col.names=F)
out <- as.data.frame(comp1.deseq2)
deseq.bed <- out[ which(out$FDR < 0.05), 
                  c("seqnames", "start", "end", "strand", "Fold")]
write.table(deseq.bed, file="GSC_vs_DGC_deseq2_sig.bed", sep="\t", quote=F, row.names=F, col.names=F)


# --- 05 进行 PCA 可视化及其他分析
dba.plotPCA(dbObj, contrast=1, label=DBA_REPLICATE)

pvals <- dba.plotBox(dbObj)
dba.plotVenn(dbObj,contrast=1,method=DBA_ALL_METHODS)
plot(dbObj)
dba.plotProfile(dbObj, doPlot=TRUE)


##------------------------------------------------------------------------------
## SECTION 2: PART 2 - MATCHED ANALYSIS
##------------------------------------------------------------------------------


##匹配 ----
meta_chip_match=read_excel("meta_chip_match.xlsx")
write.csv(meta_chip_match, "meta_chip_match.csv", row.names = FALSE,quote = F)

# --- 01 创建 DiffBind 对象进行PCA分析 ----
###确保文件都有值，不然会报错

dbObj_match <- dba(sampleSheet = "/cluster/home/futing/Project/GBM/legency/gsc/h3k27ac/meta_chip_match.csv")
###存储的是原始peaks数据，没有通过reads数进行校正
save(dbObj_match,file="dbObj_matchoriginal.data")
dba.plotPCA(dbObj_match, label=DBA_CONDITION) 

####根据原始peaks数据(peak caller score)绘制样本间相关性热图，并存储为PDF ----
#pdf("Figure1_Correlationheatmap.pdf")
#plot(dbObj_match)
#dev.off()

# --- 02 计算 Reads 并保存
###根据bam文件中reads数进行校正，这时候要读取bam文件，花费较多时间和内存。样本数越多，所需时间和内存就越 多
dbObj_match <- dba.count(dbObj_match)
save(dbObj_match,file="dbObj_matchcount.data")

###根据原校正后peaks数据(affinity scores)绘制样本间相关性热图，并存储为PDF
#pdf("Figure2_Correlationheatmap.pdf")
#plot(dbObj_match)
#dev.off()

# --- 03 计算库的大小信息
info_match <- dba.show(dbObj_match)
libsizes_match <- cbind(LibReads=info_match$Reads, FRiP=info_match$FRiP,PeakReads=round(info_match$Reads*info_match$FRiP)) 
rownames(libsizes_match) <- info_match$ID
save(libsizes_match,file="libsizes_match.data")

# --- 04 数据标准化
###对数据根据reads数进行标准化，然后储存
dbObj_match <- dba.normalize(dbObj_match,normalize=DBA_NORM_LIB)
norm_match <- dba.normalize(dbObj_match, bRetrieve=TRUE)
dba.plotPCA(dbObj_match, label=DBA_CONDITION) 

normlibs_match <- cbind(FullLibSize=norm_match$lib.sizes,
                  NormFacs=norm_match$norm.factors,
                  NormLibSize=round(norm_match$lib.sizes/norm$norm.factors))
rownames(normlibs_match) <- info_match$ID
normlibs_match
save(norm_match,file="norm_match.data")
save(normlibs_match,file="normlibs_match.data") 
save(dbObj_match,file="dbObj_matchnormlized.data")

#getwd()
load("dbObj_matchoriginal.data")
pdf("Figure1_Correlationheatmap.pdf")
dba.plotPCA(dbObj_match, label=DBA_REPLICATE) 
dev.off()
load("dbObj_matchcount.data")
dba.plotPCA(dbObj_match, label=DBA_CONDITION) 
load("libsizes.data")
load("norm.data")
load("normlibs.data")
load("dbObj_matchnormlized.data")
dba.plotPCA(dbObj_match, label=DBA_CONDITION) 
dba.plotPCA(dbObj_match, label=DBA_REPLICATE) 
#####先看一下重复间共有和特有peaks，最多也就做4个样品的venn图了，再多就报错了
#pdf("Figure 3 peaks among replicats.pdf")
#dba.plotVenn(dbObj_match,dbObj_match$masks$DGC)
#dba.plotVenn(dbObj_match,dbObj_match$masks$GSC)
#dev.off()


# --- 05 差异分析
###接下来是最重要的步骤 ###构建contrast，即差异分析分组，这直接关系到后边所有作图数据，所以这一步极其关键
dbObj_match <- dba.contrast(dbObj_match, minMembers=2,design="~Tissue + Condition")
#dbObj_match


# 差异分析
###黑名单是encode定义的，灰名单是根据input,如果没有input，就会报错
dbObj_match <- dba.analyze(dbObj_match,method=DBA_ALL_METHODS, bGreylist=FALSE)
save(dbObj_match,file="dbObana.data")
dba.show(dbObj_match, bContrasts=TRUE)
comp1.edgR_match<- dba.report(dbObj_match, method=DBA_EDGER, contrast = 1 ) 
comp1.deseq2_match<- dba.report(dbObj_match, method=DBA_DESEQ2, contrast = 1) 
dba.report

# --- 06 filter FDR < 0.05 peaks and output BED
head(comp1.deseq2_match)

# EdgeR
out <- as.data.frame(comp1.edgR_match)
edge.bed_match <- out[ which(out$FDR < 0.05), 
                 c("seqnames", "start", "end", "strand", "Fold")]
write.table(edge.bed_match, file="GSC_vs_DGC_edgeR_sig_match.bed", sep="\t", quote=F, row.names=F, col.names=F)

edge.bed_match_GSCup <- out[ which(out$FDR < 0.05 & out$Fold > 0), 
                       c("seqnames", "start", "end", "strand", "Fold")]
write.table(edge.bed_match_GSCup, file="GSC_vs_DGC_edgeR_sig_match_GSCup.bed", sep="\t", quote=F, row.names=F, col.names=F)

# DESeq2
out <- as.data.frame(comp1.deseq2_match)
deseq.bed_match <- out[ which(out$FDR < 0.05), 
                  c("seqnames", "start", "end", "strand", "Fold")]
write.table(deseq.bed_match, file="GSC_vs_DGC_deseq2_sig_match.bed", sep="\t", quote=F, row.names=F, col.names=F)
deseq.bed_match_GSCup <- out[ which(out$FDR < 0.05 & out$Fold > 0), 
                        c("seqnames", "start", "end", "strand", "Fold")]
write.table(deseq.bed_match_GSCup, file="GSC_vs_DGC_deseq2_sig_match_GSCup.bed", sep="\t", quote=F, row.names=F, col.names=F)

##------------------------------------------------------------------------------
## SECTION 3: RESULT VISUALIZATION
##------------------------------------------------------------------------------
# Count GSC upregulated and downregulated peaks 
# 柱形图
class(deseq.bed_match_GSCup$Fold)
deseq_positive <- sum(deseq.bed_match$Fold > 0)
deseq_negative <- sum(deseq.bed_match$Fold < 0)
edge_positive <- sum(edge.bed_match$Fold > 0)
edge_negative <- sum(edge.bed_match$Fold < 0)

results <- data.frame(
  Group = rep(c("deseq", "edge"), each = 2),  # 分组信息
  Sign = rep(c("GSC up", "GSC down"), times = 2),  # 符号，正或负
  Count = c(deseq_positive, deseq_negative, edge_positive, edge_negative)  # 计数
)

# 加载ggplot2包
library(ggplot2)

# 绘制分组柱状图
ggplot(results, aes(x = Group, y = Count, fill = Sign)) +
  geom_bar(stat = "identity", position = "dodge") +  # 使用dodge来避免柱子重叠
  labs(title = "Count of GSC up and down Fold Changes",
       x = "Group", y = "Count", fill = "Sign") +
  theme_minimal() +
  scale_fill_brewer(palette = "Set1") 

# Additional differential binding visualizations
pvals <- dba.plotBox(dbObj_match)
dba.plotVenn(dbObj_match,contrast=1,method=DBA_ALL_METHODS)
plot(dbObj_match)
dba.plotProfile(dbObj_match, doPlot=TRUE)

##------------------------------------------------------------------------------
## SECTION 4: PEAK ANNOTATION
##------------------------------------------------------------------------------
# Load peak files for annotation
edge.bed_match_GSCup <- readPeakFile("GSC_vs_DGC_edgeR_sig_match_GSCup.bed", as="GRanges")
deseq.bed_match_GSCup <- readPeakFile("GSC_vs_DGC_deseq2_sig_match_GSCup.bed", as="GRanges")
txdb <- TxDb.Hsapiens.UCSC.hg38.knownGene

# Create TSS profile plots
pdf("Figure2.sample_TSS_peaks_heatmap and plot.pdf")
# Define TSS regions (2.5kb upstream and downstream)
tss <- getPromoters(TxDb = txdb, upstream = 2500, downstream = 2500)
# Get tag matrix for TSS regions
tagMatrix <- getTagMatrix(edge.bed_match, windows = tss)
# Generate heatmap around TSS
#tagHeatmap(tagMatrix, xlim=c(-2500, 2500), color="red")
peakHeatmap(edge.bed_match, TxDb = txdb, upstream = 2500, downstream = 2500, color = "red")
# Plot average profile
plotAvgProf(tagMatrix, xlim = c(-2500, 2500),
            xlab = "Genomic Region (5'->3')", ylab = "Read Count Frequency")
# Plot with confidence interval
plotAvgProf(tagMatrix, xlim = c(-2500, 2500), conf = 0.95, resample = 1000)
dev.off()

# --- Annotate peaks with genomic features
peakAnno <- annotatePeak(deseq.bed_match_GSCup, tssRegion=c(-2500, 2500), TxDb=txdb, annoDb="org.Hs.eg.db")
peakAnno

write.table(
  as.data.frame(peakAnno),
  "peak.annotation.tsv",
  sep="\t",
  row.names = F,
  quote = F)

# Convert to different formats
peakAnno.df <- as.data.frame(peakAnno) #保存为数据框
peakAnno.gr <- as.GRanges(peakAnno) #保存为GenomicRanges write.table(peakAnno.df,file="sample.annotation.xls",quote=F,sep="\t")

# Visualize peak annotations
###peaks注释可视化(多种图形及最近基因)
pdf("Figure 3.sample_peaks annotation_pie_bar_venn_upset.pdf") 
plotAnnoPie(peakAnno)
plotAnnoBar(peakAnno)
vennpie(peakAnno)
dev.off()






