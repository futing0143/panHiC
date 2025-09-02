library(readxl)
library(GSVA)
library(pheatmap)
library(ComplexHeatmap)
merge1=read.table("rna/merged_output1.txt",header = T)
merge2=read.table("rna/merged_output2.txt",header = T)
merge3=read.table("rna/GSC28_TPM_new.txt",header = T)
U343=read.table("rna/gene-TPM-matrixU343.txt",header = T)
A172=read.table("rna/gene-TPM-matrixA172.txt",header = T)
merge12=merge(merge1,merge2,by="gene")
merge123=merge(merge12,merge3,by="gene")
merge1234=merge(merge123,U343,by="gene")
merged_data=merge(merge1234,A172,by="gene")
df <- merged_data[, !grepl("^gene\\.", colnames(merged_data))]
write.table(df,"allTPM.txt",quote = F, row.names = FALSE)
# 假设df是原数据框
new_matrix <- matrix(colnames(df[,2:165]), ncol = 1)
write.table(new_matrix,"colodata_allTPM.txt",quote = F, row.names = FALSE)
##linux上处理

merged_data=read.table("rna/all.txt", header = TRUE)
merged_data$gene=rownames(merged_data)

coldata=read.table("rna/allmeta.txt", header = T, sep = "\t")
#colnames(coldata)=c("filename","ID","dataset")
#colnames(merged_data[,2:165])==coldata$filename
coldata$dataset <- ifelse(grepl("^P", coldata[, 1]), "Mathur et al", coldata$dataset)
coldata <- coldata[!is.na(coldata$dataset) & coldata$dataset != "", ]
rownames(coldata)=coldata$sample
rownames(coldata) <- gsub("-", ".", rownames(coldata))


##读入TPM矩阵，用gtf注释，取log2(+1)
gtf_filter=read.table("~/Desktop/resources/genome/gtf_filter.txt")
gtf_filter$gene_id <- substr(gtf_filter$gene_id , 1, 15)
colnames(gtf_filter)[1]=c("gene")[1]
merged_data_G=merge(gtf_filter,merged_data,by="gene")
merged_data_G=merged_data_G[,c(2,4:ncol(merged_data_G))]
merged_data_G <- aggregate(. ~ gene_name, data = merged_data_G, max)
rownames(merged_data_G)=merged_data_G[,1]
write.table(merged_data_G,"all_G.txt",quote = F, row.names = FALSE)



library(sva)
merged_data_G <- merged_data_G[, rownames(coldata)]
write.table(merged_data_G,"/Users/zjl/Desktop/GBM/subtype/heatmap/TPM_149.txt",quote = F, row.names = T)
write.table(coldata,"/Users/zjl/Desktop/GBM/subtype/heatmap/coldata_149.txt",quote = F, row.names = T,sep ="\t")


##############1205从这里开始##########
merged_data_G=read.table("TPM_149.txt")
coldata=read.table("coldata_149.txt",sep = "\t", header = TRUE)
#expr_combat <- ComBat(dat = merged_data_G, batch = coldata$dataset)

merged_data_Glog=log2(merged_data_G+1)
merged_data_Glog_Z <- t(scale(t(merged_data_Glog)))
merged_data_Glog=as.matrix(merged_data_Glog_Z)
merged_data_Glog <- merged_data_Glog[complete.cases(merged_data_Glog), ]


# perform_pca_and_plot <- function(data, color, shape) {
#   data_m <- as.matrix(data)
#   pca <- prcomp(t(data_m))
#   pca_scores <- data.frame(
#     Sample = rownames(pca$x),
#     PC1 = pca$x[,1],
#     PC2 = pca$x[,2],
#     Group = color
#   )
#   
#   pca.var <- pca$sdev^2
#   pca.var.per <- round(pca.var/sum(pca.var)*100, 1)
#   
#   # 将"Neural", "Proneural", "Mesenchymal", "Classical"设置为颜色，其余为"other"
#   pca_scores$Color <- ifelse(pca_scores$Group %in% c("Neural", "Proneural", "Mesenchymal", "Classical"), pca_scores$Group, "other")
#   
#   # 绘制PCA图，着色"Neural", "Proneural", "Mesenchymal", "Classical"类别，其余为灰色
#   ggplot(pca_scores, aes(x=PC1, y=PC2, color=Color, shape=shape)) +
#     geom_point() +
#     labs(y="PC2", x="PC1") + 
#     xlab(paste("PC1 (", pca.var.per[1], "% variance)", sep="")) +
#     ylab(paste("PC2 (", pca.var.per[2], "% variance)", sep="")) +
#     theme_bw() +
#     scale_color_manual(values = c("Neural" = "blue", "Proneural" = "green", 
#                                   "Mesenchymal" = "red", "Classical" = "purple", 
#                                   "other" = "gray"))
# }

#perform_pca_and_plot(merged_data_Glog, coldata$subtype,coldata$dataset)



##读入基因set
signature_Wang2017=read_excel("../geneset_pub.xlsx",sheet = "Wang2017")
# signature_Neftel2019=read_excel("geneset_pub.xlsx",sheet = "Neftel2019")
# signature_Richards2021=read_excel("geneset_pub.xlsx",sheet = "Richards2021")

##gsva
wang2017<- gsva(merged_data_Glog, signature_Wang2017,method='ssgsea',kcdf='Gaussian',abs.ranking=TRUE)
# Neftel2019<- gsva(merged_data_Glog, signature_Neftel2019,method='ssgsea',kcdf='Gaussian',abs.ranking=TRUE)
# Richards2021<- gsva(merged_data_Glog, signature_Richards2021,method='ssgsea',kcdf='Gaussian',abs.ranking=TRUE)

##生成亚型文件
max_row_names_wang2017 <- apply(wang2017, 2, function(x) rownames(wang2017)[which.max(x)])
# max_row_names_Neftel2019 <- apply(Neftel2019, 2, function(x) rownames(Neftel2019)[which.max(x)])
# max_row_names_Richards2021 <- apply(Richards2021, 2, function(x) rownames(Richards2021)[which.max(x)])
coldata <- cbind(coldata, max_row_names_wang2017)
# coldata <- cbind(coldata, max_row_names_Neftel2019)
# coldata <- cbind(coldata, max_row_names_Richards2021)
coldata$max_row_names_wang2017 <- as.factor(coldata$max_row_names_wang2017)
# coldata$max_row_names_Neftel2019 <- as.factor(coldata$max_row_names_Neftel2019)
# coldata$max_row_names_Richards2021 <- as.factor(coldata$max_row_names_Richards2021)
write.table(coldata,"coldata_sub_all.txt",quote = F)

# 过滤 subtype 列属于目标亚型的行
# filtered_coldata <- coldata[coldata$subtype %in% c("Neural", "Proneural", "Mesenchymal", "Classical"), ]
# matching_count <- sum(filtered_coldata$subtype == filtered_coldata$max_row_names_wang2017)
# print(matching_count)
# print(nrow(filtered_coldata))
# 
# # 筛选 id 列以 P 开头的行
# filtered_coldata <- coldata[grepl("^G", coldata$id), ]
# matching_count <- sum(filtered_coldata$subtype == filtered_coldata$max_row_names_wang2017)
# print(matching_count)
# print(nrow(filtered_coldata))


###热图
library(ComplexHeatmap)
library(tidyr)
library(dplyr)
G_signature_Wang2017 <- signature_Wang2017 %>%
  pivot_longer(cols = everything(),  # 将所有列转为长表
               names_to = "Type",    # 列名转为 "Type"
               values_to = "Gene") %>%
  arrange(Type)
G_141=intersect(G_signature_Wang2017$Gene,rownames(merged_data_Glog))
G_signature_Wang2017=G_signature_Wang2017[G_signature_Wang2017$Gene %in% G_141,]

coldata <- coldata %>%
  arrange(max_row_names_wang2017)
G_filter=merged_data_Glog[rownames(merged_data_Glog) %in%G_signature_Wang2017$Gene, ]
G_filter <- G_filter[match(G_signature_Wang2017$Gene, rownames(G_filter)),match(rownames(coldata), colnames(G_filter)) ]

column_annotation <- HeatmapAnnotation(
  wang2017 = coldata$max_row_names_wang2017,
  Dataset = coldata$dataset,
  col = list(
    wang2017 = c("Classical" = "blue", "Mesenchymal" = "red", "Proneural" = "purple"))# 用于注释的列数据
)

gene_labels <- G_signature_Wang2017 %>%
#  filter(Gene %in% rownames(G_filter)) %>%  # 匹配基因名
  arrange(match(Gene, rownames(G_filter))) %>%  # 按热图行顺序排列
  pull(Type) 

row_annotation <- rowAnnotation(
  Type = factor(gene_labels),
  col = list(
    Type = c("Classical" = "blue", "Mesenchymal" = "red", "Proneural" = "purple"))# 用于注释的列数据
  
)


png("heatmap_150.png", width = 800, height = 600)  # 设置图像宽度和高度
# 绘制热图
library(colorRamp2)
my_col <- colorRamp2(c(-1, 0, 1), c("blue", "white", "red"))
Heatmap(
  G_filter,
  cluster_rows = FALSE,                  # 对基因（行）进行聚类
  cluster_columns = FALSE,              # 不对样本（列）进行聚类
  show_row_names = FALSE,               # 不显示基因名
  show_column_names = FALSE,            # 不显示列名
  top_annotation = column_annotation,
  right_annotation = row_annotation, 
  # 自定义颜色
  col = my_col
)

# 关闭设备并保存图像
dev.off()
