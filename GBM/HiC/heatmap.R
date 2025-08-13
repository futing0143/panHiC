
library(pheatmap)
library(RColorBrewer)

subtype_data=read.table('/cluster/home/futing/Project/GBM/HiC/09insulation/subtype.txt')
E1= read.table('/cluster/home/futing/Project/GBM/HiC/06compartment/cooltools_500k/E1.tsv',sep='\t',header=T)
E1 = E1[,-c(39,44,41,42,43,66)] # "ipsc","iPSC_new","NPC","NPC_new","pHGG","GBM"

colnames(E1)[c(1,49,50,51)]<- c( "42MGBA","P529.SF12794v1-1","P529.SF12794v6-1","P529.SF12794v8-1")

# 数据预处理函数
preprocess_data <- function(data) {
  #data <- data[rowSums(!is.na(data)) > 0, ]
  data[is.na(data)] <- 0
  data <- sign(data)
  return(data)
}


E1_processed <- preprocess_data(E1)
all_similarity <- cor(E1_processed)

# 创建子类型的颜色映射
subtype_colors <- c("Mesenchymal" = "#FF9999", "Classical" = "#66B2FF", "Unknown" = "#99FF99","Proneural"='#FFCC99',"Neural"='#bc020f')
annotation_colors <- list(Subtype = subtype_colors)

# 创建注释数据框
annotation_df <- data.frame(Subtype = subtype_data[,2])
annotation_df$Subtype <- factor(annotation_df$Subtype,levels=c("Mesenchymal","Classical","Unknown","Proneural","Neural"))
rownames(annotation_df) <- subtype_data[,1]
# 热图的颜色
my_colors <- colorRampPalette(c("#1065ad", "white", "#bc020f"))(100)

# 查看每个水平的计数，以确保没有意外的水平
table(annotation_df$Subtype)
# 绘制热图
#pdf("/cluster/home/futing/Project/GBM/HiC/09insulation/QC/PC1_100k_with_subtypes_R.pdf", width = 12, height = 10)
pheatmap(
  all_similarity,
  color = my_colors,
  #annotation_row = annotation_df,
  annotation_col = annotation_df,
  annotation_colors = annotation_colors,
  show_rownames = TRUE,
  show_colnames = T,
  treeheight_row = 0,
  fontsize_row = 8,
  fontsize_col = 8,
  main = "PC1 correlation with subtypes",
  cluster_rows = TRUE,
  cluster_cols = T,
  cellwidth = 10,
  cellheight = 10,
  border_color = NA
)
