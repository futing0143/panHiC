library(ggplot2)
library(clusterProfiler)
library(org.Hs.eg.db)
library(org.Mm.eg.db)
d10.5 <- read.csv(file='/Users/joanna/Documents/02.Project/Uterus/DeSeq2_en/New_en/group_d6.5_vs_Virgin.csv')
d6.5 <- read.csv(file='/Users/joanna/Documents/02.Project/Uterus/DeSeq2/New/group_d6.5_vs_Virgin.csv')
d6.5 <- d6.5[which((abs(d6.5$log2FoldChange) >1) & (d6.5$padj < 0.05)),]
gene <- d6.5$X
trans <- bitr(gene, fromType="ENSEMBL",
              toType="ENTREZID", OrgDb="org.Mm.eg.db")
trans1 <- bitr(gene, fromType="SYMBOL",toType="ENTREZID", OrgDb="org.Mm.eg.db")

##转换ID

#######################GO

ego <- enrichGO(gene = trans$ENTREZID,
                OrgDb= org.Mm.eg.db,
                ont= "ALL", #GO Ontology，可选 BP、MF、CC，也可以指定 ALL 同时计算 3 者
                pAdjustMethod = "BH",
                pvalueCutoff = 0.05,
                qvalueCutoff = 1,
                readable = TRUE)

head(ego@result)

result<-ego@result

write.csv(result,file = 'd10.5_go.result.csv',quote = F,row.names = T,col.names = T)
barplot(ego)  #富集柱形图
dotplot(ego)  #富集气泡图
cnetplot(ego) #网络图展示富集功能和基因的包含关系
emapplot(ego) #网络图展示各富集功能之间共有基因关系
heatplot(ego) #热图展示富集功能和基因的包含关系
##########################KEGG

#organism supported organism listed in 'http://www.genome.jp/kegg/catalog/org_list.html'

#hsa 人；mmu 小鼠

kk <- enrichKEGG(gene= trans1$ENTREZID,
                 pAdjustMethod = 'fdr',
                 keyType = 'kegg', 
                 organism= 'mmu',
                 pvalueCutoff = 0.05,
                 qvalueCutoff = 1)
kk@result$Description <- gsub("- .*","",kk@result$Description)
tmp <- data.frame(kk)
kkx <- setReadable(kk, 'org.Mm.eg.db', 'ENTREZID')
kk<- data.frame(kkx)

write.csv(kk,file = 'd8.5_kegg.result.csv',quote = F,row.names = T,col.names = T)

barplot(kk)

####0------------ GSEA
info <- read.csv(file='/Users/joanna/Documents/02.Project/胎盘NK/DeSeq2_en/New_en/group_d11.5_vs_Virgin.csv')[,c(1,3,6,7)]
names(info) <- c('ENSEMBL','Log2FoldChange','pvalue','padj')
info_merge <- merge(info,trans,by='ENSEMBL')#合并转换后的基因ID和Log2FoldChange
GSEA_input <- info_merge$Log2FoldChange
names(GSEA_input) = info_merge$ENTREZID
GSEA_input = sort(GSEA_input, decreasing = TRUE)
GSEA_KEGG <- gseKEGG(GSEA_input, organism = 'mmu', pvalueCutoff = 0.05)#GSEA富集分析
GSEA_KEGG@result$Description <- gsub("- .*","",GSEA_KEGG@result$Description)
ridgeplot(GSEA_KEGG,label_format = 50)
