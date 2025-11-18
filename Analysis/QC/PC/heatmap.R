pacman::p_load(readxl,ggplot2,egg,janitor,reshape2,RColorBrewer,dplyr,stringr,ComplexHeatmap,circlize) #,harrypotter,ochRe,dutchmasters
setwd('/cluster2/home/futing/Project/panCancer/Analysis/QC/PC')

# ------- 01 read in data
meta =read.csv('/cluster2/home/futing/Project/panCancer/Analysis/QC/PC/PC1016.txt',sep='\t',check.names = F,header=F)
colnames(meta) = c('cancer','gse','cell','ncell')
data=read.csv('/cluster2/home/futing/Project/panCancer/Analysis/QC/PC/merged_col5.tsv',sep='\t',check.names = F)

# 清洗一下数据
df_clean <- data %>%
  as_tibble() %>%  
  dplyr::select(-chrom, -start, -end) %>%
  # na.omit(axis=1)
  filter(rowSums(is.na(.)) / ncol(.) <= 0.5) #  533153,327
# data_fil <- replace(df_clean, is.na(df_clean), 0)

# !!! 实际上直接从cluster_scatter_pca.R获得df_clean就可以了
top_features <- order(apply(df_clean, 2, var, na.rm = TRUE), 
                      decreasing = TRUE)[1:10000]

cor_mat_fil <- colnames(cor_mat[, colSums(cor_mat < 0) >= 0.5*nrow(cor_mat)])
data_reduced <- df_clean[top_features,!colnames(df_clean) %in% cor_mat_fil]


# ------ 02 相关性



corinsul_re <- cor(data_reduced, use = "pairwise.complete.obs")
# corinsul = cor(data_fil,use="pairwise.complete.obs")
meta=meta[!meta$ncell %in% cor_mat_fil,]
# meta=meta[match(colnames(corinsul_re),meta$ncell),] %>% drop_na()
meta$cancer = factor(meta$cancer)

# corinsul_fil <- replace(corinsul_re, is.na(corinsul_re), 0)
write.table(corinsul_re,file="CorPC_top1w.txt",sep='\t')



# ------ 画图
annotation_col <- data.frame(factor(meta$cancer))
rownames(annotation_col) <- meta$ncell
colnames(annotation_col) <- 'Cancer'

set1 <- RColorBrewer::brewer.pal(11, "Paired") 
gradient_colors <- colorRampPalette(set1)(33) #%>% rev()
# annocolors= list(
#   Cancer= c(TALL="#16365F",MB="#77A3BB",CRC="#D64F38")
# )
annocolors <- list(
  Cancer = setNames(gradient_colors, unique(meta$cancer))
)

# ------- pheatmap ------
# plot(1:32, rep(1, 32), col = annocolors, pch = 19, cex = 5)
pheatmap::pheatmap(corinsul_re,         
                   annotation_col = annotation_col, 
                   annotation_colors = annocolors,
                   color = colorRampPalette(c("#00688B", "#FFFFFF","red"))(100),
                   # cluster_cols = T,
                   show_rownames = F,
                   show_colnames = F, 
                   scale = "none",  # 相关矩阵不应该缩放
                   ## none, row, column         
                   fontsize = 12,         
                   fontsize_row = 8,         
                   fontsize_col = 6,         
                   border = FALSE,         
                   treeheight_row = 0,
                   filename = 'heatmapPC_1028.pdf')


# --- method 2 

cor_mat = corinsul_re

M <- max(abs(min(cor_mat, na.rm = TRUE)), abs(max(cor_mat, na.rm = TRUE)))

# 2. 创建以 0 为中心的对称颜色函数
col_fun = colorRamp2(
  c(-M, 0, M), 
  c("#4575b4", "white", "#d73027") # 使用更专业的蓝色和红色
) 

# 3. 绘制热图
# 把 annotation_col 转成 HeatmapAnnotation
ha <- HeatmapAnnotation(
  df = annotation_col,
  col = annocolors,
  annotation_legend_param = list(
    ncol = 2,  # 🔹图例分两行（相当于两列）
    title_gp = gpar(fontsize = 10),
    labels_gp = gpar(fontsize = 8)
  )
)

ht <- Heatmap(
  cor_mat,
  name = "Cor(PC1)",
  col = col_fun,
  show_row_names = FALSE,
  show_column_names = FALSE,
  cluster_rows = T,
  cluster_columns = T,
  top_annotation = ha,
  heatmap_legend_param = list(title = "Cor (PC1)")
)
ht

# 找到最蓝的部分

