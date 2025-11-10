pacman::p_load(readxl,ggplot2,egg,janitor,reshape2,RColorBrewer,dplyr,stringr,ComplexHeatmap,circlize) #,harrypotter,ochRe,dutchmasters
setwd('/cluster2/home/futing/Project/panCancer/Analysis/QC/PC')

# ------- 01 read in data
meta =read.csv('/cluster2/home/futing/Project/panCancer/Analysis/QC/PC/PC1016.txt',sep='\t',check.names = F,header=F)
data=read.csv('/cluster2/home/futing/Project/panCancer/Analysis/QC/PC/merged_col5.tsv',sep='\t')

# 清洗一下数据
rownames(insul) = paste0('insul_',c(1:617669))
df_clean <- insul %>%
  as_tibble() %>%  
  dplyr::select(-chrom, -start, -end) %>%
  # na.omit(axis=1)
  filter(rowSums(is.na(.)) / ncol(.) <= 0.5) #  533153,327
# data_fil <- replace(df_clean, is.na(df_clean), 0)

# !!! 实际上直接从cluster_scatter_pca.R获得df_clean就可以了
top_features <- order(apply(df_clean, 2, var, na.rm = TRUE), 
                      decreasing = TRUE)[1:10000]
data_reduced <- df_clean[top_features,]

# ------ 02 相关性
corinsul_re <- cor(data_reduced, use = "pairwise.complete.obs")
# corinsul = cor(data_fil,use="pairwise.complete.obs")
meta=meta[match(colnames(corinsul_re),meta$ncell),]
meta$cancer = factor(meta$cancer)

corinsul_fil <- replace(corinsul_re, is.na(corinsul_re), 0)
write.table(corinsul_re,file="CorPC_top1w.txt",sep='\t')
# 绘图
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
col_fun <- colorRamp2(c(-1, 0, 1), c("#00688B", "#FFFFFF", "red"))

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
  corinsul_re,
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

min_col_index <- which.min(colMeans(corinsul_re, na.rm = TRUE))
bluest_column <- corinsul_re[, min_col_index]
bluest_column_name <- colnames(corinsul_re)[min_col_index]

reordered_row_names <- rownames(corinsul_re)[row_order(ht)]
reordered_col_names <- colnames(corinsul_re)[col_order(ht)]

dys <- corinsul_re %>% as.data.frame() %>%
  filter(if_any(everything(), ~ . < 0))

dys <- corinsul_re %>% as.data.frame() %>%
  filter(if_all(everything(), ~ . < 0))
