library(clusterProfiler)
library(org.Hs.eg.db)
library(enrichplot)
library(ggplot2)
# -- mutation gene analysis
setwd('/cluster/home/futing/Project/GBM/HiC/HAR')

# 示例基因列表
HARs_diff =read.csv('/cluster/home/futing/Project/GBM/HiC/HAR/HARs_gene/genes/long/HARsgene_RNA.txt',sep='\t')
# 63,3
HARs_diff <- read.csv('/cluster/home/futing/Project/GBM/HiC/HAR/HARs_gene/genes/long/HARsgene_GBMdiff_bygene.txt',sep='\t')
# 624,3

cell='NPC'
gene_list <- HARs_diff[HARs_diff$CellType==cell,'Gene'] %>% unique()

entrez_ids <- bitr(gene_list, fromType = "SYMBOL", 
                   toType = "ENTREZID", 
                   OrgDb = org.Hs.eg.db)

# GO分析
ego <- enrichGO(gene = entrez_ids$ENTREZID, 
                OrgDb = org.Hs.eg.db, 
                ont = "BP", 
                pAdjustMethod = "BH", 
                pvalueCutoff = 0.1, #0.05
                qvalueCutoff = 0.3, #0.2
                readable = TRUE)
dotplot(ego)
result <- as.data.frame(ego)
write.table(result,paste0('/cluster/home/futing/Project/GBM/HiC/HAR/plot/GO_result',cell,'_filbygene_GO.txt'),sep='\t',row.names =F)
ggsave(paste0("/cluster/home/futing/Project/GBM/HiC/HAR/plot/GO_result/",cell,"_filbygene_GO.pdf"), width=7, height=6)

# ---------- KEGG
kk <- enrichKEGG(gene = entrez_ids$ENTREZID, 
                 pAdjustMethod = 'fdr',
                 keyType = 'kegg',
                 organism = 'hsa',
                 pvalueCutoff = 0.1,
                 qvalueCutoff = 1)
## 6.3 Visualize results
barplot(kk)
# --------------------- Batch GO
# 转换基因为Entrez ID
HARs=unique(HARs_diff[HARs_diff$CellType=='NPC',]$HAR)
error_HARs <- c()
  
for (HAR in HARs) {
gene_list <- HARs_diff[((HARs_diff$HAR == HAR) & (HARs_diff$CellType=='GBM')),'Gene'] %>% unique()
  gene_list <- HARs_diff[,'Gene'] %>% unique()

  tryCatch({
    entrez_ids <- bitr(gene_list, fromType = "SYMBOL", 
                       toType = "ENTREZID", 
                       OrgDb = org.Hs.eg.db)
    
    # GO分析
    ego <- enrichGO(gene = entrez_ids$ENTREZID, 
                    OrgDb = org.Hs.eg.db, 
                    ont = "BP", 
                    pAdjustMethod = "BH", 
                    pvalueCutoff = 0.1, #0.05
                    qvalueCutoff = 0.3, #0.2
                    readable = TRUE)
    
    tryCatch({
      dotplot(ego)
      # ggsave(paste0("/cluster/home/futing/Project/GBM/HiC/HAR/plot/GO_result/", HAR, "_GO.pdf"), width=7, height=6)
      ggsave(paste0("/cluster/home/futing/Project/GBM/HiC/HAR/plot/GO_result/GBM_filbygene_GO.pdf"), width=7, height=6)
      
      error_HARs <<- c(error_HARs, HAR)
    }, error = function(e) {
      cat("Error in generating dotplot for HAR: ", HAR, "\n", "Error message: ", e$message, "\n")
      
    })
    
  }, error = function(e) {
    error_HARs <<- c(error_HARs, HAR)
    cat("Error in converting gene symbols to Entrez IDs for HAR: ", HAR, "\n", "Error message: ", e$message, "\n")
  })
}

head(ego@result)

result<-ego@result

write.csv(result,file = 'd10.5_go.result.csv',quote = F,row.names = T,col.names = T)
barplot(ego)  #富集柱形图
   #富集气泡图
cnetplot(ego) #网络图展示富集功能和基因的包含关系
emapplot(ego) #网络图展示各富集功能之间共有基因关系
heatplot(ego) #热图展示富集功能和基因的包含关系


#--- KEGG
#organism supported organism listed in 'http://www.genome.jp/kegg/catalog/org_list.html'

#hsa 人；mmu 小鼠

kk <- enrichKEGG(gene= entrez_ids$ENTREZID,
                 pAdjustMethod = 'fdr',
                 keyType = 'kegg', 
                 organism= 'hsa',
                 pvalueCutoff = 0.05,
                 qvalueCutoff = 1)
kk@result$Description <- gsub("- .*","",kk@result$Description)
tmp <- data.frame(kk)
kkx <- setReadable(kk, 'org.Hs.eg.db', 'ENTREZID')
kk<- data.frame(kkx)

write.csv(kk,file = 'd8.5_kegg.result.csv',quote = F,row.names = T,col.names = T)

barplot(kk)

####0------------ GSEA
info <- read.table(file='/cluster/home/futing/Project/GBM/HiC/13mutation/mutation_tcga/ConRNA_looped.txt',sep='\t',header = T)

info <- info %>%
  mutate(logcontact = scale(log10(rawcontact + 1)))
entrez_ids <- bitr(info$SYMBOL, fromType = "SYMBOL", 
                   toType = "ENTREZID", 
                   OrgDb = org.Hs.eg.db)
info=merge(info,entrez_ids,by='SYMBOL')
# names(info) <- c('ENSEMBL','Log2FoldChange','pvalue','padj')
# info_merge <- merge(info,trans,by='ENSEMBL')#合并转换后的基因ID和Log2FoldChange
GSEA_input <- info$logcontact
names(GSEA_input) = info$ENTREZID
GSEA_input = sort(GSEA_input, decreasing = TRUE)
GSEA_KEGG <- gseKEGG(GSEA_input, organism = 'hsa', pvalueCutoff = 0.05)#GSEA富集分析
GSEA_KEGG@result$Description <- gsub("- .*","",GSEA_KEGG@result$Description)
ridgeplot(GSEA_KEGG,label_format = 50)


