library(clusterProfiler)
library(org.Hs.eg.db)
library(enrichplot)
library(ggplot2)


# 示例基因列表
setwd('/cluster/home/futing/Project/GBM/HiC/10loop/consensus/cytoscape')
# loop=read.csv('/cluster/home/futing/Project/GBM/HiC/10loop/consensus/result/subtype/subtype_symbol.txt',sep='\t')
loop=read.csv('/cluster/home/futing/Project/GBM/HiC/10loop/consensus/cytoscape/RNA_loop.txt',sep='\t')
loop = loop[,-1]
loop = na.omit(loop)
cell='GBM'
looptype='E-P'
cells=c('GBM','NPC','NHA','iPSC')
loops=c('E-P','P-P')
for(cell in cells){
  for (looptype in loops){
    gene_list <- loop[(loop$cell==cell) & (loop$looptype ==looptype),'gene']
    # 转换基因为Entrez ID
    entrez_ids <- bitr(gene_list, fromType = "SYMBOL", 
                       toType = "ENTREZID", 
                       OrgDb = org.Hs.eg.db)
    
    # GO分析
    ego <- enrichGO(gene = entrez_ids$ENTREZID, 
                    OrgDb = org.Hs.eg.db, 
                    ont = "BP", 
                    pAdjustMethod = "BH", 
                    pvalueCutoff = 0.05, 
                    qvalueCutoff = 0.2, 
                    readable = TRUE)
    
    # 可视化
    dotplot(ego, showCategory = 10)
    ggsave(paste0(cell,"_",looptype,"_GO.pdf"), width=7, height=6)
    
  }
}


# 转换基因为Entrez ID
entrez_ids <- bitr(gene_list, fromType = "SYMBOL", 
                   toType = "ENTREZID", 
                   OrgDb = org.Hs.eg.db)

# GO分析
ego <- enrichGO(gene = entrez_ids$ENTREZID, 
                OrgDb = org.Hs.eg.db, 
                ont = "BP", 
                pAdjustMethod = "BH", 
                pvalueCutoff = 0.05, 
                qvalueCutoff = 0.2, 
                readable = TRUE)

# 可视化
dotplot(ego, showCategory = 10)
barplot(ego, showCategory = 10)
emapplot(ego)
cnetplot(ego, circular = TRUE, colorEdge = TRUE)

# 保存结果
write.csv(as.data.frame(ego), file = paste0("./plot/GO_",loop,"_",cell,".csv"), row.names = FALSE)
