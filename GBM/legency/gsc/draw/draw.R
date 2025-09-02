#安装 ----
if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
.libPaths("/desired/library/path")

BiocManager::install("topGO",force =TRUE)
BiocManager::install("tidyverse")
install.packages(c("ggplot2", "dplyr","pheatmap"))
BiocManager::install(c("ChIPQC", "ChIPseeker", "clusterProfiler", "AnnotationDbi", "TxDb.Hsapiens.UCSC.hg38.knownGene"))
BiocManager::install("DOSE", version = "3.23",force = TRUE)
install.packages("/cluster/home/jialu/biosoft/clusterProfiler_4.12.0.tar.gz", repos = NULL, type = "source")
devtools::install_github("YuLab-SMU/clusterProfiler",force = TRUE)
install.packages('HDO.db',repos='http://cran.us.r-project.org')
install.packages('HDO.db', dependencies=TRUE, repos='http://cran.rstudio.com/')

library(tidyverse)
library(ggplot2)
library(org.Hs.eg.db)
library(tximport)
#library("TxDb.Hsapiens.UCSC.hg38.knownGene")
library(DESeq2)
library(sva)
library(pheatmap)
library(topGO)
library(survival)
library(survminer)
library(dplyr)
library(data.table)
library(clusterProfiler)
#没用 注释1:只有enst和ensg ----
library(GenomicFeatures)
library(tximportData)
dir <- system.file("extdata", package = "tximportData")
list.files(dir)
tx2gene <- read.csv(file.path(dir, "tx2gene.gencode.v27.csv"))
head(tx2gene)


#没用 注释2:只有enst和ensg ----
txdb=makeTxDbFromGFF(
  "/cluster/share/ref_genome/hg38/annotation/gencode.v38.annotation.gtf",
  format = "gtf", dataSource = "gencode.v38.annotation.gtf", organism = "Homo sapiens"
)
txTogene <- AnnotationDbi::select(txdb, keys=keys(txdb, "TXNAME"), keytype="TXNAME", columns=c("TXNAME", "GENEID"))
txTogene=txTogene[,c(2,1)]

#注释法3: ----
gtf_filter = read.table("/cluster/home/jialu/genome/gtf_filter.txt", header=TRUE)
gtf_filter = gtf_filter[gtf_filter$gene_type=="protein_coding",]
colnames(gtf_filter)[1]="TXNAME"
colnames(gtf_filter)[2]="GENEID"

# 读入rsem文件---- 
filePaths <- readLines("/cluster/home/jialu/GBM/gsc/draw/match_add.txt")
names(filePaths) <- basename(filePaths)
txi.rsem <- tximport(filePaths, type = "rsem", txIn = FALSE, txOut = FALSE,tx2gene = gtf_filter)
txi.sum <- summarizeToGene(txi.rsem, gtf_filter) ##从转录本水平变成基因水平


##abundanceMatTx存放"TPM"；countsMatTx存放"NumReads"；lengthMatTx存放"EffectiveLength"。
##去掉所有样本都表达为0的基因，不然下一步会报all(lengths > 0) is not TRUE的错
txi.sum$abundance <-txi.sum$abundance[apply(txi.sum$length,1,function(row) all(row !=0 )),]
txi.sum$counts <-txi.sum$counts[apply(txi.sum$length,1,function(row) all(row !=0 )),]
txi.sum$length <-txi.sum$length[apply(txi.sum$length, 1,function(row) all(row !=0 )),]

view(txi.sum$counts[which(rownames(txi.sum$counts) == "CTC-432M15.3"), ])


#读入meta ----
match_meta=read.table("/cluster/home/jialu/GBM/gsc/draw/meta_match.txt",header = TRUE)
match_meta$type=as.factor(match_meta$type)
match_meta$batch=as.factor(match_meta$batch)
match_meta$pair=as.factor(match_meta$pair)
match_meta$type <- relevel(match_meta$type, ref = "DGC")
row.names(match_meta) <- match_meta$gene

save(gtf_filter,match_meta,txi.rsem,txi.sum,file="/cluster/home/jialu/GBM/gsc/draw/rsem2deseq.data")

load("/cluster/home/jialu/GBM/gsc/draw/rsem2deseq.data")


#deseq ----
##配对https://support.bioconductor.org/p/62357/#62368
ddsTxi <- DESeqDataSetFromTximport(txi.sum, match_meta, design=~ batch +  pair + type)
rld <- rlogTransformation(ddsTxi) #DEseq2自己的方法标准化数据`,样本量少于30的话，选择rlog，多于30的话，建议选择vst。
dds <- DESeq(ddsTxi)
res <- results(dds, pAdjustMethod = "fdr", alpha = 0.05)
results_match_all=as.data.frame(res)
results_match_all=na.omit(results_match_all)


###deseq自带pca图 ----
#原始数据画图 ---- 
pdf("Deseq2_pca_raw.pdf")
plotPCA(rld, intgroup='batch', returnData=TRUE) # 绘制以batch分组的PCA图
plotPCA(rld, intgroup='type') 
dev.off()

###limma去除batch画图 ----
mat <- assay(rld)
mm <- model.matrix(~type, colData(rld))
mat <- limma::removeBatchEffect(mat, batch=rld$batch, design=mm)
assay(rld) <- mat
pdf("Deseq2_pca_remo.pdf")
plotPCA(rld, intgroup='batch') # 绘制以batch分组的PCA图
plotPCA(rld, intgroup='type') 
dev.off()



###design其他尝试 ----
ddsTxi1 <- DESeqDataSetFromTximport(txi.sum, match_meta, design=~ batch + type)
rld1 <- rlogTransformation(ddsTxi1) #DEseq2自己的方法标准化数据`,样本量少于30的话，选择rlog，多于30的话，建议选择vst。
dds1 <- DESeq(ddsTxi1)
res1 <- results(dds1, pAdjustMethod = "fdr", alpha = 0.05)
results_match_all1=as.data.frame(res1)
results_match_all1=na.omit(results_match_all1)


ddsTxi2 <- DESeqDataSetFromTximport(txi.sum, match_meta, design=~type)
rld2 <- rlogTransformation(ddsTxi2) #DEseq2自己的方法标准化数据`,样本量少于30的话，选择rlog，多于30的话，建议选择vst。
dds2 <- DESeq(ddsTxi2)
res2 <- results(dds2, pAdjustMethod = "fdr", alpha = 0.05)
results_match_all2=as.data.frame(res2)
results_match_all2=na.omit(results_match_all2)


#pca图 ----
##选取部分基因
diff_genes <- subset(results_match_all, padj < 0.05 & abs(log2FoldChange) > 1)
exprs_data <- assay(dds)
row_indices <- match(rownames(diff_genes), rownames(exprs_data))
exprs_diff_genes <- exprs_data[row_indices, ]


#pca_result <- prcomp(t(exprs_diff_genes), scale. = TRUE)
#pca_scores <- pca_result$x
#pca_scores_with_type <- cbind(pca_scores, Type = match_meta$type, batch = match_meta$batch)
#pca_scores_with_type=as.data.frame(pca_scores_with_type)
#pca_scores_with_type$batch <- as.factor(pca_scores_with_type$batch)
#pca_scores_with_type$Type <- as.factor(pca_scores_with_type$Type)

create_pca_scores_with_type <- function(exprs_diff_genes, match_meta) {
  # 执行主成分分析 (PCA)
  pca_result <- prcomp(t(exprs_diff_genes), scale. = TRUE)
  pca_scores <- pca_result$x
  
  # 将PCA得分与类型和批次信息合并
  pca_scores_with_type <- cbind(pca_scores, Type = match_meta$type, batch = match_meta$batch)
  pca_scores_with_type <- as.data.frame(pca_scores_with_type)
  
  # 将批次和类型列转换为因子类型
  pca_scores_with_type$batch <- as.factor(pca_scores_with_type$batch)
  pca_scores_with_type$Type <- as.factor(pca_scores_with_type$Type)
  
  # 返回处理后的数据框
  return(pca_scores_with_type)
}

# 使用示例：
# 假设 exprs_diff_genes 是您的基因表达矩阵，match_meta 是包含类型和批次信息的元数据数据框
pca_scores_with_type <- create_pca_scores_with_type(exprs_diff_genes, match_meta)
pca_scores_with_type <- create_pca_scores_with_type(txi.sum$counts, match_meta)

# 绘制PCA图
ggplot(pca_scores_with_type, aes(x=PC1, y=PC2, color=Type)) + 
  geom_point() + 
  labs(title="PCA Plot with Type Color Coding", x="PC1", y="PC2", color="Type") +
  guides() -> p
ggsave("pca_plot_Type.png", p,width= 9 , height= 6)


#区分上调下调 ----
cut_off_pvalue = 0.05  #统计显著性
cut_off_logFC = 1           #差异倍数值

# 根据阈值参数，上调基因设置为‘up’，下调基因设置为‘Down’，无差异设置为‘Stable’，并保存到change列中
results_match_all$change = ifelse(results_match_all$padj < cut_off_pvalue & abs(results_match_all$log2FoldChange) >= cut_off_logFC, 
                                  ifelse(results_match_all$log2FoldChange> cut_off_logFC ,'Up','Down'),
                                  'Stable')
results_match_all$gene_name=rownames(results_match_all)

write.csv(results_match_all, "/cluster/home/jialu/GBM/gsc/draw/results_match_all.csv", row.names = T,quote = F)



#没用 直接读入矩阵----
match_mean=read.table("/cluster/home/jialu/GBM/gsc/draw/mean_values_by_gene_match.txt",header = TRUE)
match_mean=read.table("/cluster/home/jialu/GBM/gsc/draw/mean_values_by_gene_untreated.txt",header = TRUE)
match_meta=read.table("/cluster/home/jialu/GBM/gsc/draw/meta_untreated.txt",header = TRUE)

model <- model.matrix(~as.factor(match_meta$type))
rownames(match_mean)=match_mean$gene_name
match_mean=match_mean[,-1]



#combat没用 如果是deseq不用单独去除批次 ----
combat_match_mean <- ComBat(dat = match_mean,batch = match_meta$batch,mod = model)
write.table(combat_match_mean,"/cluster/home/jialu/GBM/gsc/draw/combat_match_mean.txt",sep = "\t", quote = FALSE)

#普通deseq2 ----
##https://bioconductor.org/packages/devel/bioc/vignettes/DESeq2/inst/doc/DESeq2.html
round_match_mean=round(match_mean) #deseq读入需要是整数
ddsMat_match <- DESeqDataSetFromMatrix(countData = round_match_mean,
                                     colData = match_meta,
                                     design = ~type+batch)
ddsMat_match <- DESeq(ddsMat_match)

#热图 ----
##Suvà et al., 2014 
genes_of_interest <- c("OLIG1", "OLIG2", "SOX2", "SOX8", "ASCL1", "POU3F3", "HES6","POU3F2",  
                       "SOX21", "HEY2",   "SOX5",  "RFX4",  "KLF15", "CITED1","LHX2",  
                       "VAX2","MYCL1","SALL2", "SOX1" )

genes_of_interest <- c("ASCL1", "HES6", "KLF15", "LHX2", "OLIG1", "OLIG2", 
                       "POU3F2", "POU3F3", "RFX4", "SALL2", "SOX1", "SOX2", 
                       "SOX21", "SOX5", "SOX8", "VAX2")

##Patel et al., 2014 
genes_of_interest <- c("METTL7B","SCG2","HEPN1", "FABP7","PTPRZ1","AGT","CCND2","SPARCL1","GPM6A","ETV1","IDH1", "GLUL", "GAP43","ATP1B2",  "PNMA2", "MARCKS", "MAP2",
                       "SEMA6D", "NFIA", "MAPK1IP1L","CPVL","GRIA2", "FXYD6", "SDCBP", "TCF12","CLU","PMP2", "PJA2","ARRDC3", 
                       "CALM1","RUFY3", "TSPAN3","TSC22D1", "PIK3R3","SEC11C", "FDFT1","FAM59B","DDX3X","PCMTD2", "DHRS7", "HAS2","IDI1", "ENO2",
                       "PCDHGA2", "APC", "MAGED1", "ZNF260", "NONO", "MTRNR2L8","MAPRE2", "RFXANK", "PLTP")
genes_of_interest <- c("ARRDC3", "ATP1B2", "CALM1", "CCND2", "CLU", "CPVL", "DDX3X", "DHRS7", "EGFR", "ENO2", "ETV1", "FABP7", "FDFT1", "FXYD6", "GAP43", "GLUL", "GPM6A", "GRIA2", "HAS2", "HEPN1", "IDH1", "IDI1", "MAGED1", "MAPK1IP1L", "MAPRE2", "MARCKS", "METTL7B", "MSH5-SAPCD1", "MTRNR2L8", "NFIA", "NONO", "PCMTD2", "PIK3R3", "PJA2", "PLTP", "PMP2", "PNMA2", "RFXANK", "RUFY3", "SCG2", "SDCBP", "SEC11C", "SEMA6D", "SMAP2", "SPARCL1", "TCF12", "TSC22D1", "TSPAN3", "ZNF260")

# 从归一化数据中选择这些基因
ntd=normTransform(dds)
ntd_data <- assay(ntd)
selected_data <- ntd_data[genes_of_interest, ]
selected_data <- as.matrix(selected_data)
type_levels <- levels(match_meta$type)
selected_data <- selected_data[, order(match_meta$type)]
annotation_data <- match_meta[order(match_meta$type), 2:4]

# 绘制热图，不显示列名，并使用排序后的注释信息
pheatmap(selected_data, 
         cluster_rows = FALSE, 
         cluster_cols = TRUE, 
         annotation_col = annotation_data,
         show_colnames = FALSE)



up_count <- 0
down_count <- 0
stable_count <- 0
for (gene in genes_of_interest) {
  # 检查该基因的状态
  gene_status <- results_match_all$change[rownames(results_match_all) == gene]
  print(gene_status)
  # 根据状态更新计数器
#  if (length(gene_status) > 0) {
#    if (gene_status == "up") {
#      up_count <- up_count + 1
#    } else if (gene_status == "down") {
#      down_count <- down_count + 1
#    } else if (gene_status == "stable") {
#      stable_count <- stable_count + 1
  #    }
  # }
}

# 输出结果
cat("Up-regulated genes:", up_count, "\n")
cat("Down-regulated genes:", down_count, "\n")
cat("Stable genes:", stable_count, "\n")


#火山图 ----
results_match_all$change <- as.factor(results_match_all$change)
str(results_match_all)
# 使用count()函数对change列进行计数
category_counts <- table(results_match_all$change)

top_up_genes <- results_match_all %>%
  filter(change == "Up") %>%
  arrange(desc(-padj)) %>%
  head(5)

top_down_genes <- results_match_all %>%
  filter(change == "Down") %>%
  arrange(desc(-padj)) %>%
  head(5)

# 合并上调和下调的基因，用于在图上标注
top_genes <- bind_rows(top_up_genes, top_down_genes)

# 绘制火山图，并在图例中显示每个类型的数量
v=ggplot(results_match_all, aes(x = log2FoldChange, y = -log10(padj), colour = change)) +
  geom_point(alpha = 0.4, size = 1) +
  scale_color_manual(
    values = c("#546de5", "#d2dae2", "#ff4757"),  # 颜色映射
    labels = paste0(names(category_counts), " (", category_counts, ")"),  # 添加类别名称和数量
    drop = FALSE  # 即使某些颜色在数据中没有对应的点，图例中的项也不会被删除
  ) +
  geom_vline(xintercept = c(-1, 1), lty = 4, col = "black", lwd = 0.8) +
  geom_hline(yintercept = -log10(cut_off_pvalue), lty = 4, col = "black", lwd = 0.8) +
  labs(x = "log2(fold change)", y = "-log10 (p-value)") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5),
        legend.position = "right",
        legend.title = element_blank(),
        legend.text = element_text(size = 14)) +
  guides(colour = guide_legend(override.aes = list(size = 3.5)))+ geom_text(data = top_genes, aes(label = gene_name), 
                                                                            vjust = 2, hjust = 1.5, color = "black", size = 2.8)
ggsave("valcon.png", v, width= 9 , height= 6)


#富集分析气泡图/在本机跑，服务器的R版本不够KEGG ----
##一列基因
up <- results_match_all[results_match_all$change == "Up",]$gene_name
down <- results_match_all[results_match_all$change == "Down",]$gene_name

enrich.go <- enrichGO(gene = down,  #待富集的基因列表
                      OrgDb = "org.Hs.eg.db",  #指定物种的基因数据库，示例物种是绵羊（sheep）
                      keyType = 'SYMBOL',  #指定给定的基因名称类型，例如这里以 entrze id 为例
                      ont = 'ALL',  #GO Ontology，可选 BP、MF、CC，也可以指定 ALL 同时计算 3 者
                      pAdjustMethod = 'fdr',  #指定 p 值校正方法
                      pvalueCutoff = 0.05,  #指定 p 值阈值（可指定 1 以输出全部）
                      qvalueCutoff = 0.2,  #指定 q 值阈值（可指定 1 以输出全部）
                      readable = FALSE)
head(enrich.go)
write.table(enrich.go, '/cluster/home/jialu/GBM/gsc/draw/enrich.go.txt', sep = '\t', row.names = FALSE, quote = FALSE)
#dotplot(enrich.go,title="EnrichmentGO_GSC_downreg")

go <- read.delim('/cluster/home/jialu/GBM/gsc/draw/enrich.go.txt', stringsAsFactors = FALSE)
go$term <- paste(go$ID, go$Description, sep = ': ')

go <- go[order(go$p.adjust), ]
go <- head(go, 20)
go$term <- factor(go$term, levels = go$term)

ggplot(go, aes(term, -log10(p.adjust))) +
  geom_col(aes(fill = ONTOLOGY), width = 0.5, show.legend = FALSE) +
  scale_fill_manual(values = c('#D06660', '#5AAD36', '#6C85F5')) +
  facet_grid(ONTOLOGY~., scale = 'free_y', space = 'free_y') +
  theme(panel.grid = element_blank(), panel.background = element_rect(color = 'black', fill = 'transparent')) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.1))) + 
  coord_flip() +
  labs(x = '', y = '-Log10 P-Value\n')


####KEGG 在本机
up_entrez <- bitr(up,
                    fromType = "SYMBOL",#现有的ID类型
                    toType = "ENTREZID",#需转换的ID类型
                    OrgDb = "org.Hs.eg.db")
kegg <- enrichKEGG(
  gene = up_entrez$ENTREZID,  #基因列表文件中的基因名称
  keyType = 'kegg',  #例如，oas 代表绵羊，其它物种更改这行即可
  pAdjustMethod = 'fdr',#指定 p 值校正方法
  pvalueCutoff = 0.05,  #指定 p 值阈值（可指定 1 以输出全部）
  qvalueCutoff = 0.2)  #指定 q 值阈值（可指定 1 以输出全部）

packageVersion('clusterProfiler')
#输出结果
write.table(kegg, 'kegg.txt', sep = '\t', quote = FALSE, row.names = FALSE)



#生存分析 ----
load("/cluster/home/jialu/GBM/gsc/draw/tcga/GBMsurvive.RData")
matrix$TXNAME=rownames(matrix)
matrix_=merge(matrix,gtf_filter,by="TXNAME")
##转为数值型
for (i in 2:176) {
  matrix_[[i]] <- as.numeric(as.character(matrix_[[i]]))
}

# 检查转换后的列的数据类型
sapply(matrix_, class)
matrix_1=matrix_[,c(177,2:176)]

# 检查数据类型，确保转换成功
matrix_1$avg_expression <- apply(matrix_1[, 2:176], 1, mean)


# 对数据框进行排序，先按基因名称（genename）进行排序，然后再按平均表达值降序排列
# 这样确保了具有相同基因名称的行会放在一起，并且平均表达值最高的行会排在最前面
matrix_1 <- matrix_1[order(matrix_1$GENEID, matrix_1$avg_expression, decreasing = TRUE), ]

# 选择每个基因名称对应的最大平均值的行
# 由于我们已经按基因名称和平均表达值排序，因此可以直接选择第一行
# 这里假设每个基因名称是唯一的，如果有重复的基因名称，需要进一步处理
max_rows <- matrix_1[!duplicated(matrix_1$GENEID), ]

# 如果需要，可以移除辅助列 avg_expression
max_rows <- max_rows[, -which(names(max_rows) == "avg_expression")]
rownames(max_rows)=max_rows$GENEID
max_rows=max_rows[,2:176]



#筛选和排序，获取前5个上调基因 ----
top200_upregulated_genes <- results_match_all %>%
  dplyr::filter(change == "Up") %>%  # 明确指定使用dplyr包中的filter函数
  dplyr::arrange(dplyr::desc(log2FoldChange)) %>%  # 同样明确指定arrange和desc函数
  head(37) %>%
  dplyr::pull(gene_name) %>%
  as.list()

# 根据筛选出的基因名创建子集矩阵
matrix0_sub <- max_rows[rownames(max_rows) %in% top200_upregulated_genes, , drop = FALSE]

# 向量化计算每列的均值并创建新行
means <- colMeans(matrix0_sub, na.rm = TRUE)
new_row <- data.frame(lapply(means, function(x) x))
colnames(new_row) <- colnames(matrix0_sub)

# 添加均值行到矩阵
gene175_expression_new <- rbind(matrix0_sub, new_row)
rownames(gene175_expression_new)[nrow(gene175_expression_new)] <- "mean"

# 转置矩阵并创建分组
transposed_gene175 <- t(gene175_expression_new)
transposed_gene175 <- as.data.frame(transposed_gene175)
transposed_gene175$GE_group <- ifelse(transposed_gene175$mean > median(transposed_gene175$mean, na.rm = TRUE), 'higher', 'lower')

# 匹配元数据并计算生存分析
meta$GE_group <- with(transposed_gene175, ifelse(substr(rownames(transposed_gene175), 1, 12) %in% rownames(meta), GE_group, NA))

# 执行生存分析
sfit <- survfit(Surv(time, event) ~ GE_group, data = meta)
ggsurvplot(sfit, conf.int = F, pval = TRUE)

# 计算 p 值
surv_diff <- survdiff(Surv(time, event) ~ GE_group, data = meta)
p.value <- 1 - pchisq(surv_diff$chisq, length(surv_diff$n) - 1)
pval_info = surv_pvalue(sfit)
p_value <- pval_info$pval[1]


# 假设其他代码和变量定义如上文所示

#初始化一个空的数据框来存储结果 ----
output_data <- data.frame()

# 循环从1到50，计算每个top基因的p值 
for (i in 1:200) {
  # 筛选top i个基因
  top_i_genes <- results_match_all %>%
    dplyr::filter(change == "Up") %>%  # 明确指定使用dplyr包中的filter函数
    dplyr::arrange(dplyr::desc(log2FoldChange)) %>%  # 同样明确指定arrange和desc函数
    head(i) %>%
    dplyr::pull(gene_name) %>%
    as.list()
  
  # 根据筛选出的基因名创建子集矩阵
  matrix0_sub <- max_rows[rownames(max_rows) %in% top_i_genes, , drop = FALSE]
  
  # 向量化计算每列的均值并创建新行
  means <- colMeans(matrix0_sub, na.rm = TRUE)
  new_row <- data.frame(lapply(means, function(x) x))
  colnames(new_row) <- colnames(matrix0_sub)
  
  # 添加均值行到矩阵
  gene_expression_new <- rbind(matrix0_sub, new_row)
  rownames(gene_expression_new)[nrow(gene_expression_new)] <- "mean"
  
  # 转置矩阵并创建分组
  transposed_gene <- t(gene_expression_new)
  transposed_gene <- as.data.frame(transposed_gene)
  transposed_gene$GE_group <- ifelse(transposed_gene$mean > median(transposed_gene$mean, na.rm = TRUE), 'higher', 'lower')
  
  # 匹配元数据并计算生存分析
  meta$GE_group <- with(transposed_gene, ifelse(substr(rownames(transposed_gene), 1, 12) %in% rownames(meta), GE_group, NA))
  
  # 执行生存分析
  sfit <- survfit(Surv(time, event) ~ GE_group, data = meta)
  pval_info = surv_pvalue(sfit)
  p_value <- pval_info$pval[1]
  # 计算 p 值
#  surv_diff <- survdiff(Surv(time, event) ~ GE_group, data = meta)
#  p_value <- 1 - pchisq(surv_diff$chisq, length(surv_diff$n) - 1)
  
  # 将结果添加到数据框中
  output_data <- rbind(output_data, data.frame(
    `Top Gene` = i,
    p_value = p_value
  ))
}

# 将数据框写入到 CSV 文件
#write.csv(output_data, "top_genes_p_values.csv", row.names = FALSE)


#GSEA ----
###https://zhuanlan.zhihu.com/p/518144716https://zhuanlan.zhihu.com/p/518144716 
organism = 'hsa'    #  人类'' 小鼠'mmu'   
OrgDb = 'org.Hs.eg.db'
need_DEG <- results_match_all[,c(2,5,8)]
colnames(need_DEG) <- c('log2FoldChange','pvalue','SYMBOL')
df <- bitr(rownames(need_DEG), 
           fromType = "SYMBOL",
           toType =  "ENTREZID",
           OrgDb = OrgDb) #人数据库org.Hs.eg.db 小鼠org.Mm.eg.db
need_DEG <- merge(need_DEG, df, by='SYMBOL')  #按照SYMBOL合并注释信息
geneList <- need_DEG$log2FoldChange
names(geneList) <- need_DEG$ENTREZID
geneList <- sort(geneList, decreasing = T)

KEGG_kk_entrez <- gseKEGG(geneList     = geneList,
                          organism     = organism, #人hsa 鼠mmu
                          pvalueCutoff = 0.25)  #实际为padj阈值,可调整 
KEGG_kk <- DOSE::setReadable(KEGG_kk_entrez, 
                             OrgDb=OrgDb,
                             keyType='ENTREZID')#转化id             

GO_kk_entrez <- gseGO(geneList     = geneList,
                      ont          = "ALL",  # "BP"、"MF"和"CC"或"ALL"
                      OrgDb        = OrgDb,#人类org.Hs.eg.db 鼠org.Mm.eg.db
                      keyType      = "ENTREZID",
                      pvalueCutoff = 0.25)   #实际为padj阈值可调整
GO_kk <- DOSE::setReadable(GO_kk_entrez, 
                           OrgDb=OrgDb,
                           keyType='ENTREZID')#转化id 

save(KEGG_kk_entrez, GO_kk_entrez, file = "GSEA_result.RData")








