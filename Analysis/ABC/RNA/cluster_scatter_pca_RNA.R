pacman::p_load(FactoMineR,ggplot2,magrittr,RColorBrewer,knitr,reshape2,extrafont,ggpubr,gridExtra,tibble)
# Import fonts from the system
font_import()
loadfonts()
par(family = "Arial")
setwd('/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA')

# -------------------------- 01 read in processed data
data=TPM_fil
cancer_meta=read.csv('/cluster2/home/futing/Project/panCancer/check/meta/cancer_category/Cancer_catecoded.csv',check.names=F)
RNAmeta=left_join(metadatan,cancer_meta[,c(1,3,4)],by=c('cancer'='Abbreviation'))
RNAmeta$`General Category`[is.na(RNAmeta$`General Category`)] <- 3
RNAmeta$`General Category` <- factor(RNAmeta$`General Category`,
                                  levels = c(4, 1, 2, 3),
                                  labels = c("Solid Tumor", 
                                             "Hematological (Leukemia)", 
                                             "Hematological (Lymphoma)", 
                                             "Normal Tissue"))
RNAmeta$`Primary Site / Origin` <- factor(RNAmeta$`Primary Site / Origin`,
                                           levels = c(1,2,3,4,5,6,7,8),
                                           labels = c("Hematological", 
                                                      "Reproductive System", 
                                                      "Urinary System", 
                                                      "Digestive System",
                                                      "Central Nervous System",
                                                      "Epithelial tumors",
                                                      "Neural crest derived tumors",
                                                      "Mesenchymal tumors"))
colnames(RNAmeta)[6:7]<- c('Cancer_Category','Origin')
write.table(RNAmeta,'/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/results/RNAmeta.txt',sep='\t',quote=F,row.names = F)
save(RNAmeta,df_filtered,file="/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/TPM1211.RData")

# --- 预处理
# 行是基因列是样本
data %>% sum()%>% is.na()

# df_clean <- data %>%
#   as_tibble() %>%
#   # 只计算数值列的NA比例
#   filter(rowSums(is.na(across(where(is.numeric)))) / 
#            ncol(across(where(is.numeric))) <= 0.5)

top_features <- order(apply(data, 1, var, na.rm = TRUE), 
                      decreasing = TRUE)[1:10000]
# 按照E1的方差排序，选择最前面的
# fil <- as.integer(0.2 * length(data_var))
# top_var_indices <- order(data_var, decreasing = TRUE)[1:(fil + 1)] # order 返回的是按顺序的索引
# df_filtered[, apply(df_filtered, 1, var, na.rm = TRUE) > 0] #去掉全是NA的
df <- data[top_features,] %>% t() %>%
  replace(., is.na(.), 0)

# 去掉方差为0的列
df <- t(TPM_fil)
zero_var_cols <- which(apply(df, 2, var, na.rm = TRUE) == 0)
if (length(zero_var_cols) > 0) {
  cat("移除的常数列:", colnames(df)[zero_var_cols], "\n")
  df_filtered <- df[, -zero_var_cols]
} else {
  df_filtered <- df
}

#--------------------------- 02 running PCA
#d1log2 <- log(d1,2)
#pc1_fil0<- scale(pc1_fil0,center=T,scale=T)

# -- method 1
library(missMDA)

# 首先对缺失值进行插补
df_imputed <- imputePCA(df, ncp = 5, scale = TRUE)$completeObs
# 然后在插补后的数据上进行PCA分析
com1 <- PCA(df_imputed, scale.unit = TRUE, ncp = 5, graph = FALSE)
com1 <- PCA(df, scale.unit = TRUE, ncp = 5, graph = FALSE)

# -- method2

com1_RNA <- prcomp(df_filtered , center = T,scale = TRUE)

# 02 提取PC score并确定分组###
RNA_pca<-com1_RNA$x %>% as.data.frame(.) %>% 
  rownames_to_column(var = "ncell") 

RNA_pca =merge(RNAmeta,RNA_pca,by.x='header',by.y='ncell')
RNA_pca$cancer <-factor(RNA_pca$cancer)
RNA_pca$Datasource <-factor(RNA_pca$Datasource)
write.table(RNA_pca,'/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/results/1211/RNAPC_1211_all.txt',
            sep='\t',row.names =F,quote=F)


summ<-summary(com1)
xlab<-paste0("PC1 (",round(summ$importance[2,1]*100,2),"%)")
ylab<-paste0("PC2 (",sprintf("%0.2f", summ$importance[2,2]*100),"%)")
g <- guide_legend("cancer")
set1 <- RColorBrewer::brewer.pal(11, "Paired") 
gradient_colors <- colorRampPalette(set1)(37) #%>% rev()

# ------ PCA plot
source('/cluster2/home/futing/Project/panCancer/Analysis/plot_function.R')

colnames(RNA_pca)[c(5,6)] <- c('X1','X2')
pcacancer <- plot_umap_fill(RNA_pca,"cancer","Cancers",xlab=xlab,ylab=ylab,colors = gradient_colors,legendexist=F)
pcacancer

ggsave("./plot/1211/TPM_CancerType_PCA1211.pdf", egg::set_panel_size(pcacancer, width=unit(4, "in"), height=unit(4, "in")), 
       width = 8, height = 6, units = 'in')

#-------------- 05 kmeans
set.seed(123) 
pca_result = RNA_pca
kmeans_result <- kmeans(pca_result[8:28],center=3)
pca_result['kmeans']=kmeans_result$cluster
pca_result$kmeans <- factor(pca_result$kmeans,levels=c(1:3))

# ----- 05 plot kmeans
set1 <- RColorBrewer::brewer.pal(11, "Paired") 
gradient_colors <- colorRampPalette(set1)(37) #%>% rev()

pcacancer <- plot_umap_fill(pca_result,"cancer","Cancers",colors = gradient_colors,legendexist=F)
pcacancer
pcasource <- plot_umap_fill(pca_result, "Datasource", "Data Source",legendexist = F)
pcasource
pcaCancerCate <- plot_umap_fill(pca_result, "Cancer_Category", "Cancer Categories",legendexist=F)
pcaCancerCate
pca_result[is.na(pca_result$Origin),'Origin']='Normal'
pcaorigin <- plot_umap_fill(pca_result, "Origin", "Origin",legendexist=F,colors = gradient_colors2)
pcaorigin
pcakmeans <- plot_umap_fill(pca_result, "kmeans","Clusters")
pcakmeans


# 额外添加legend
pukmeans_legend <- plot_legend(pca_result,'kmeans',"Clusters")
pucancer_legend <- plot_legend(pca_result,'cancer',"Cancers",gradient_colors)
pusource_legend <- plot_legend(pca_result,"Datasource","Data Source")
puorgin_legend <- plot_legend(pca_result,"Origin","Origin",gradient_colors2)
pucancertypes_legend <- plot_legend(pca_result,'Cancer_Category','Cancer Categories')

# --- merge all the plots

# lay = rbind(c(1,1,2,2,3))
#lay <- matrix(c(1, 1, 2), nrow = 1, byrow = TRUE)
# grid.arrange(p2,pcacancer, pcakmeans,arrangeGrob(pcakmeans_legend,pcacancer_legend,ncol = 1, nrow =2),layout_matrix = lay,padding = unit(0.01, "cm"))

# --- 组合1
lay <- rbind(c(1,1,2,2,3,3,4,4))
# 构建 legend 区域：
# 左边为 pcacancer_legend
# 右边为上下排列的 pcasource_legend 和 pcakmeans_legend
legend_block <- arrangeGrob(
  pcacancer_legend,
  arrangeGrob(pcasource_legend, pcakmeans_legend, ncol = 1),
  ncol = 2,
  widths = c(1, 1)
)

# 最终组合
combined_plot<- grid.arrange(p2,pcasource,pcakmeans,
  legend_block,
  layout_matrix = lay,
  padding = unit(0.01, "cm")
)
final_plot <- arrangeGrob(
  p2, pcasource, pcakmeans,
  legend_block,
  layout_matrix = lay,
  padding = unit(0.01, "cm")
)
final_plot
combined_plot
ggsave("./plot/1211/TPM_combined_all.pdf", final_plot, width = 20, height = 5)

# ------ 组合2
legend_col1 <- arrangeGrob(pucancer_legend,ncol = 1)

legend_col2 <- arrangeGrob(
  pusource_legend,
  pukmeans_legend,
  pucancertypes_legend,
  puorgin_legend,
  ncol = 1
)

right_block <- arrangeGrob(
  legend_col1,
  legend_col2,
  ncol = 2,
  widths = c(1, 1)
)

# --- Left block (2×2 main plots) ---
left_block <- arrangeGrob(
  pucancer, pusource,
  pukmeans, puCancerCate,
  puorigin,
  ncol = 2
)

# --- Layout matrix ---
lay <- rbind(
  c(1, 1, 2),
  c(1, 1, 2),
  c(1, 1, 2)
)

# --- Final arrange ---
combined_PC_plot<- grid.arrange(
  left_block,
  right_block,
  layout_matrix = lay,
  padding = unit(0.01, "cm")
)

ggsave("/Users/joanna/Documents/02.Project/GBM/05code/RNA/RNAbatchcorrected_UMAP_combined_kmeans_5_1212.pdf", combined_PC_plot, width = 15, height = 10)

#===========================
#---- 添加label
#prb <- 
  ggplot(RNA_pca, aes(x=PC1,y = PC2,fill=kmeans)) +
  geom_point(stroke=0.35,shape=21,size=3,color="black",alpha=0.8)+
  labs(x=xlab,y=ylab,fill="Dataset")+
    scale_fill_brewer(palette = 'Dark2')+ 
  #geom_smooth(formula=y~x,color="red",method = lm,se=FALSE)+
  #annotate('text',x=0.75,y=-0.8,label=paste("R =",cor_GH,sep = " "),size=4,fontface="bold")+####系数和坐标要修改
  #scale_x_continuous(expand=c(0,0),limits=c(-1.2,1.2))+
  #scale_y_continuous(expand=c(0,0),limits = c(-1.2,1.2))+
  theme_bw()+####去掉灰色背景
  theme(plot.title = element_text(hjust=0.5,size=12, face=2,family="sans"),
        plot.background = element_rect(fill = NA, colour = NA),####去掉绘图背景
        axis.title = element_text(family = "sans",face="bold",size=12),
        axis.text.x =  element_text(colour="black", size=11),
        axis.text.y =  element_text(colour="black", size=11),
        axis.ticks = element_line(colour="black",linewidth = 0.5),
        axis.line = element_blank(),
        panel.border = element_rect(fill=NA,color="black",linewidth = 1,linetype = 1),
        panel.grid = element_blank(),###去掉网格线
        legend.position = "right")+ # +
  ggrepel::geom_label_repel(aes(label=sample),RNA_pca,
                            size = 2, #注释文本的字体大小
                            box.padding = 0.3, #字到点的距离
                            point.padding = 0.5, #字到点的距离，点周围的空白宽度
                            min.segment.length = 0.4, #短于某长度隐藏
                            segment.color = "black", #segment.colour = NA, 不显示线段
                            show.legend = F,
                            fill=NA,
                            max.overlaps = getOption("ggrepel.max.overlaps", default = 50))


ggsave("Cor_GH.pdf", egg::set_panel_size(prb, width=unit(4, "in"), height=unit(4, "in")), 
       width = 10, height = 8, units = 'in')