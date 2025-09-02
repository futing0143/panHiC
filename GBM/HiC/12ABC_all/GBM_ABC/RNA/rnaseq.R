library(DESeq2)

library(ggplot2)
library(clusterProfiler)
library(biomaRt)
#library(ReactomePA)
library(DOSE)
##library(KEGG.db)
library(org.Hs.eg.db)

library(pheatmap)
library(genefilter)
library(RColorBrewer)
library(GO.db)
library(topGO)
library(dplyr)
library(gage)
library(ggsci)
library(tidyverse)
library(data.table)
library(enrichplot)
library(ggpubr)
#library(ggthemes)


#读入分组文件；
coldata <- read.table("sample_annotation.txt",sep = " ",header=T)
coldata_ts543=coldata[1:3,]

#读入原始Counts(cts);
tpm_gbm <- read.table("gene-count-matrix_gbm.txt",header=T)
tpm_gbm[,1]=substr(tpm_gbm[,1],1,15)

rownames(tpm_gbm)=tpm_gbm[,1]
tpm_gbm=tpm_gbm[,-1]
tpm_gbm_543=tpm_gbm[,1:3]
tpm_gbm_543 <- round(tpm_gbm_543, digits = 0)

# - countData : count dataframe
# - colData : sample metadata in the dataframe with row names as sampleID's
# - design : The design of the comparisons to use. 
#            Use (~) before the name of the column variable to compare
ddsMat <- DESeqDataSetFromMatrix(countData = tpm_gbm_543,
                                 colData = coldata_ts543,
                                 design = ~condition)


# Find differential expressed genes
ddsMat <- DESeq(ddsMat)

# Get results from testing with FDR adjust pvalues
results <- results(ddsMat, pAdjustMethod = "fdr", alpha = 0.05)

# Generate summary of testing. 
summary(results)

# Check directionality of the log2 fold changes
## Log2 fold change is set as (LoGlu / HiGlu)
## Postive fold changes = Increased in LoGlu
## Negative fold changes = Decreased in LoGlu
mcols(results, use.names = T)

rownames(results)=substr(rownames(results),1,15)
results=aggregate(.~rownames(results),mean,data=results)

# Add gene full name
results$description <- mapIds(x = org.Hs.eg.db,
                              keys = row.names(results),
                              column = "GENENAME",
                              keytype = "ENSEMBL",
                              multiVals = "first")

# Add gene symbol
results$symbol <- row.names(results)

# Add ENTREZ ID
results$entrez <- mapIds(x = org.Hs.eg.db,
                         keys = row.names(results),
                         column = "ENTREZID",
                         keytype = "SYMBOL",
                         multiVals = "first")

# Add ENSEMBL
results$ensembl <- mapIds(x = org.Hs.eg.db,
                          keys = row.names(results),
                          column = "ENSEMBL",
                          keytype = "SYMBOL",
                          multiVals = "first")

# Subset for only significant genes (q < 0.05)
results_sig <- subset(results, padj < 0.05)

# Write normalized gene counts to a .txt file
write.table(x = as.data.frame(counts(ddsMat), normalized = T), 
            file = '/cluster/home/haojie/ytnormalized_counts.txt', 
            sep = '\t', 
            quote = F,
            col.names = NA)

# Write significant normalized gene counts to a .txt file
write.table(x = counts(ddsMat[row.names(results_sig)], normalized = T), 
            file = '/cluster/home/haojie/ytnormalized_counts_significant.txt', 
            sep = '\t', 
            quote = F, 
            col.names = NA)

# Write the annotated results table to a .txt file
write.table(x = as.data.frame(results), 
            file = "/cluster/home/haojie/ytresults_gene_annotated.txt", 
            sep = '\t', 
            quote = F,
            col.names = NA)

# Write significant annotated results table to a .txt file
write.table(x = as.data.frame(results_sig), 
            file = "/cluster/home/haojie/ytresults_gene_annotated_significant.txt", 
            sep = '\t', 
            quote = F,
            col.names = NA)


# Convert all samples to rlog
ddsMat_rlog <- rlog(ddsMat, blind = FALSE)

# Plot PCA by column variable
plotPCA(ddsMat_rlog, intgroup = "Group", ntop = 500) +
  theme_bw() + # remove default ggplot2 theme
  geom_point(size = 5) + # Increase point size
  scale_y_continuous(limits = c(-5, 5)) + # change limits to fix figure dimensions
  ggtitle(label = "Principal Component Analysis (PCA)", 
          subtitle = "Top 500 most variable genes") 

####Volcano Plot
# Gather Log-fold change and FDR-corrected pvalues from DESeq2 results
## - Change pvalues to -log10 (1.3 = 0.05)
data <- data.frame(gene = row.names(results),
                   pval = -log10(results$padj), 
                   lfc = results$log2FoldChange)
data <- na.omit(data)

# Color the points which are up or down
## If fold-change > 0 and pvalue > 1.3 (Increased significant)
## If fold-change < 0 and pvalue > 1.3 (Decreased significant)
data <- mutate(data, color = case_when(data$lfc > 0 & data$pval > 1.3 ~ "Increased",
                                       data$lfc < 0 & data$pval > 1.3 ~ "Decreased",
                                       data$pval < 1.3 ~ "nonsignificant"))
# vol <- ggplot(data, aes(x = lfc, y = pval, color = color))
# vol +   
#   ggtitle(label = "Volcano Plot", subtitle = "Colored by fold-change direction") +
#   geom_point(size = 2.5, alpha = 0.8, na.rm = T) +
#   scale_color_manual(name = "Directionality",
#                      values = c(Increased = "#008B00", Decreased = "#CD4F39", nonsignificant = "darkgray")) +
#   theme_bw(base_size = 14) + # change overall theme
#   theme(legend.position = "right") + # change the legend
#   xlab(expression(log[2]("LoGlu" / "HiGlu"))) + # Change X-Axis label
#   ylab(expression(-log[10]("adjusted p-value"))) + # Change Y-Axis label
#   geom_hline(yintercept = 1.3, colour = "darkgrey") + # Add p-adj value cutoff line
#   scale_y_continuous(trans = "log1p") # Scale yaxis due to large p-values

data$Label = ""
data <- data[order(abs(data$lfc),decreasing = T), ]
log2FC.genes <- head(data$gene, 20)
data <- data[order(abs(data$pval),decreasing = T), ]
fdr.genes <- head(data$gene, 20)
deg.top20.genes <- c(as.character(log2FC.genes), as.character(fdr.genes))
data$Label[match(deg.top20.genes, data$gene)] <- deg.top20.genes
ggscatter(data, x = "lfc", y = "pval",
          color = "color", 
          palette = c("#00BA38",  "#F8766D", "#BBBBBB"),
          size = 1.5,
          label = data$Label, 
          font.label = 10, 
          repel = T,
          xlab = "log2FC", 
          ylab = "pval") + 
  theme_base() + 
  geom_hline(yintercept = 1.30, linetype="dashed") +
  geom_vline(xintercept = c(-2,2), linetype="dashed")
