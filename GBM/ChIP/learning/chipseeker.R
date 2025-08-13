library(ChIPseeker)
library(TxDb.Hsapiens.UCSC.hg38.knownGene)
library(clusterProfiler)
library(org.Mm.eg.db)
library(ReactomePA)
library(ArchR)
setwd('~/Project/GBM/eqtl/CTCF')
txdb <-TxDb.Hsapiens.UCSC.hg38.knownGene

# 1 读入 peak
gbm3565 <- readPeakFile('/cluster/home/futing/Project/GBM/eqtl/CTCF/GSE139416/GSM4141365_GBM3565.CTCF.narrowPeak.bed',header=F)
gsc <- readPeakFile('/cluster/home/futing/Project/GBM/eqtl/CTCF/GSE139416/GSM4141366_GSC23.CTCF.narrowPeak.bed',header=F)
peaklist <- list(gbm3565=gbm3565,gsc=gsc)

# 2 查看peak在基因组中的位置
covplot(gbm3565,weightCol = 'V5')
# 可以单独查看某些染色体和区域
covplot(gbm3565, weightCol="V5", chrs=c("chr17", "chr18"), xlim=c(4.5e7, 5e7))

# 2.2 TSS 附近 peak 的情况 
promoter <- getPromoters(TxDb=txdb, upstream=3000, downstream=3000)
tagMatrix <- lapply(peaklist, getTagMatrix, windows=promoter)
tagHeatmap(tagMatrix, xlim=c(-3000, 3000), color=NULL)

plotAvgProf(tagMatrix, xlim=c(-3000, 3000),
            xlab="Genomic Region (5'->3')",
            ylab = "Read Count Frequency", facet="row")

plotAvgProf(tagMatrix, xlim=c(-3000, 3000),
            xlab="Genomic Region (5'->3')",
            ylab = "Read Count Frequency")

# 3 peak 注释
gbm3565_Anno <- annotatePeak(gbm3565, tssRegion=c(-3000, 3000),
                          TxDb=txdb, annoDb="org.Hs.eg.db", verbose=FALSE)
as.GRanges(gbm3565_Anno)
write.table(as.data.frame(cbx7_Anno), "Anno/cbx7.anno.xls", quote=F, row.names=F, sep="\t")
anno_list <- lapply(peaklist, annotatePeak, TxDb=txdb, tssRegion=c(-3000, 3000), verbose=FALSE, annoDb="org.Hs.eg.db")

# 4 peak 可视化
plotAnnoPie(gbm3565_Anno)
vennpie(gbm3565_Anno)
upsetplot(gbm3565_Anno)
plotAnnoBar(anno_list)
plotDistToTSS(anno_list,
              title="Distribution of transcription factor-binding loci\nrelative to TSS")

# 5 富集分析
# 代码是没有问题的，但服务器网不行
genes = lapply(anno_list, function(i) as.data.frame(i)$geneId)
names(genes) = sub("_", "\n", names(genes))
compKEGG <- compareCluster(geneCluster=genes, fun="enrichKEGG", organism='hsa',pvalueCutoff=0.05, pAdjustMethod="BH")
dotplot(compKEGG, showCategory=15, title="KEGG Pathway Enrichment Analysis")

require(clusterProfiler)
bedfile=getSampleFiles()
# 将bed文件读入（readPeakFile是利用read.delim读取，然后转为GRanges对象）
seq=lapply(bedfile, readPeakFile)

genes1=lapply(peaklist, function(i) 
  seq2gene(i, c(-1000, 3000), 3000, TxDb=txdb))
cc = compareCluster(geneClusters = genes, 
                    fun="enrichKEGG", organism="hsa")
dotplot(cc, showCategory=10)
# 6 Venn
genes = lapply(anno_list, function(i) as.data.frame(i)$geneId)
vennplot(genes)
