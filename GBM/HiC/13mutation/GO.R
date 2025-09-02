library(clusterProfiler)
library(org.Hs.eg.db)
library(enrichplot)
library(ggplot2)
# -- mutation gene analysis

# 示例基因列表
SM_gene=read.csv('/cluster/home/futing/Project/GBM/HiC/13mutation/SM_gene.csv',sep='\t')
SM_genec= SM_gene %>% filter(!ENSG == "" ) %>% unique() #获得所有互作基因

# 转换基因为Entrez ID
patientlist=unique(SM_genec$Tumor_Sample_Barcode) #所有的patient
hg19symbol=unique(SM_genec$hg19id) # 所有hg19id

gene_list=SM_genec[SM_genec$hg19id==hg19symbol[2],'symbol']
gene_list=SM_genec[SM_genec$Tumor_Sample_Barcode==patientlist[1],'symbol']
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

head(ego@result)

result<-ego@result

write.csv(result,file = 'd10.5_go.result.csv',quote = F,row.names = T,col.names = T)
barplot(ego)  #富集柱形图
dotplot(ego)  #富集气泡图
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


