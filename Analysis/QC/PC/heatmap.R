pacman::p_load(readxl,ggplot2,egg,janitor,reshape2,RColorBrewer,dplyr,stringr) #,harrypotter,ochRe,dutchmasters
setwd('/cluster2/home/futing/Project/panCancer/Analysis/QC/insul')

# 01 read in data
insul=read.csv('/cluster2/home/futing/Project/panCancer/QC/insul/cancer_327.bed',sep='\t',header=T,check.names = F)
colnames(insul) <- make.unique(colnames(insul),sep='_')

meta =read.csv('/cluster2/home/futing/Project/panCancer/check/hic/insul0910.txt',sep='\t',check.names = F,header=F)
colnames(meta)=c('cancer','gse','cell','ncell')
meta$cell <- make.unique(meta$cell,sep='_')

# 清洗一下数据
rownames(insul) = paste0('insul_',c(1:617669))
df_clean <- insul %>%
  as_tibble() %>%  
  dplyr::select(-chrom, -start, -end) %>%
  # na.omit(axis=1)
  filter(rowSums(is.na(.)) / ncol(.) <= 0.5) #  533153,327
# data_fil <- replace(df_clean, is.na(df_clean), 0)
top_features <- order(apply(df_clean, 2, var, na.rm = TRUE), 
                      decreasing = TRUE)[1:10000]
data_reduced <- df_clean[top_features,]

# 相关性
corinsul_re <- cor(data_reduced, use = "pairwise.complete.obs")
# corinsul = cor(data_fil,use="pairwise.complete.obs")
meta=meta[match(colnames(corinsul_re),meta$ncell),]
corinsul_fil <- replace(corinsul_re, is.na(corinsul_re), 0)
write.table(corinsul_re,file="Cor_top1w.txt",sep='\t')
# 绘图
annotation_col <- data.frame(factor(meta$cancer))
rownames(annotation_col) <- meta$ncell
colnames(annotation_col) <- 'Cancer'

set1 <- RColorBrewer::brewer.pal(11, "Paired") 
gradient_colors <- colorRampPalette(set1)(32) #%>% rev()
# annocolors= list(
#   Cancer= c(TALL="#16365F",MB="#77A3BB",CRC="#D64F38")
# )
annocolors <- list(
  Cancer = setNames(gradient_colors, unique(meta$cancer))
)
# plot(1:32, rep(1, 32), col = annocolors, pch = 19, cex = 5)
pheatmap::pheatmap(corinsul_fil,         
                   annotation_col = annotation_col, 
                   annotation_colors = annocolors,
                   color = colorRampPalette(c("#00688B", "#FFFFFF","red"))(100),
                   # cluster_cols = T,
                   show_rownames = F,
                   show_colnames = F, 
                   scale = "none",  # 相关矩阵不应该缩放
                   cluster_rows = !any(is.na(corinsul_fil)),  # 如果有NA就不聚类
                   cluster_cols = !any(is.na(corinsul_fil)),
                   # scale = "row",
                   ## none, row, column         
                   fontsize = 12,         
                   fontsize_row = 8,         
                   fontsize_col = 6,         
                   border = FALSE,         
                   treeheight_row = 0,
                   filename = 'heatmap327.pdf')
