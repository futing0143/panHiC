pacman::p_load(FactoMineR,ggplot2,magrittr,RColorBrewer,knitr,reshape2,extrafont,ggpubr,gridExtra,tibble)
# Import fonts from the system
font_import()
loadfonts()
par(family = "Arial")
setwd('/cluster2/home/futing/Project/panCancer/Analysis/QC/PC')

# -------------------------- 01 read in processed data
PClist =read.csv('/cluster2/home/futing/Project/panCancer/Analysis/QC/PC/PC1218.txt',sep='\t',check.names = F,header=F)
data=read.csv('/cluster2/home/futing/Project/panCancer/Analysis/QC/PC/merged_col5.tsv',sep='\t',check.names=F)
depth=read.csv('/cluster2/home/futing/Project/panCancer/Analysis/QC/nContacts/hicInfo/hicInfocl_1218.txt',sep='\t',check.names=F,header=F)
cancer_meta=read.csv('/cluster2/home/futing/Project/panCancer/check/meta/cancer_category/Cancer_catecoded.csv',check.names=F)

colnames(PClist) = c('cancer','gse','cell','ncell')
colnames(depth)=c('cancer','gse','cell','ucell','isctrl','istreated','ncell','depth')
PCmeta=merge(PClist,depth[,c('isctrl','ncell','depth')],by='ncell')
PCmeta=left_join(PCmeta,cancer_meta[,c(1,3,4)],by=c('cancer'='Abbreviation'))
PCmeta$`General Category`[is.na(PCmeta$`General Category`)] <- 3
PCmeta$`General Category` <- factor(PCmeta$`General Category`,
                                  levels = c(4, 1, 2, 3),
                                  labels = c("Solid Tumor", 
                                             "Hematological (Leukemia)", 
                                             "Hematological (Lymphoma)", 
                                             "Normal Tissue"))
PCmeta$`Primary Site / Origin` <- factor(PCmeta$`Primary Site / Origin`,
                                      levels = c(1,2,3,4,5,6,7,8),
                                      labels = c("Hematological", 
                                                 "Reproductive System", 
                                                 "Urinary System", 
                                                 "Digestive System",
                                                 "Central Nervous System",
                                                 "Epithelial tumors",
                                                 "Neural crest derived tumors",
                                                 "Mesenchymal tumors"))
colnames(PCmeta)[7]='Cancer_Category'
colnames(PCmeta)[8]="Origin"
dim(PCmeta)
PCmeta = PCmeta %>%
  mutate(
    Cancer_Category = as.character(Cancer_Category),
    Cancer_Category = ifelse(isctrl == 1, "Normal", Cancer_Category),
    Cancer_Category = factor(Cancer_Category)
  )

write.table(PCmeta,'/cluster2/home/futing/Project/panCancer/Analysis/QC/PC/PC530meta.txt',sep='\t',row.names = F,quote=F)


# --- 预处理
rownames(data) = paste0('PC_',c(1:nrow(data)))
PCdf_clean <- data %>%
  as_tibble() %>%  
  dplyr::select(-chrom, -start, -end) %>%
  # na.omit(axis=1)
  filter(rowSums(is.na(.)) / ncol(.) <= 0.5) # 26632,   526
(rowSums(is.na(data)) == 0) %>% sum() # df:519 data:1713/1699 PCdf_clean:1713全都有数值的行

top_features <- order(apply(PCdf_clean, 1, var, na.rm = TRUE), 
                      decreasing = TRUE)[1:10000]
# 按照E1的方差排序，选择最前面的
# fil <- as.integer(0.2 * length(data_var))
# top_var_indices <- order(data_var, decreasing = TRUE)[1:(fil + 1)] # order 返回的是按顺序的索引
# df_filtered[, apply(df_filtered, 1, var, na.rm = TRUE) > 0] #去掉全是NA的

PCinput <- PCdf_clean[top_features,] %>% t() %>%
  replace(., is.na(.), 0)
dim(PCinput) #530,10000
#d1log2 <- log(d1,2)
#--------------------------- 02 running PCA

# -- method 1
library(missMDA)

# 首先对缺失值进行插补
PCinput_imputed <- imputePCA(PCinput, ncp = 5, scale = TRUE)$completeObs
# 然后在插补后的数据上进行PCA分析
com1 <- PCA(PCinput_imputed, scale.unit = TRUE, ncp = 5, graph = FALSE)
com1 <- PCA(PCinput, scale.unit = TRUE, ncp = 5, graph = FALSE)

# -- method2 
PCcom1 <- prcomp(PCinput, center = T,scale = TRUE)
var_ratio <- PCcom1$sdev^2 / sum(PCcom1$sdev^2)
cum_var <- cumsum(var_ratio)
cum_var[1:20]
which(cum_var >= 0.8)[1] #88
which(cum_var >= 0.9)[1] #163
library(vegan)
bs <- bstick(PCcom1$sdev^2)
# 累计plot
plot(cum_var, type = "b",
     xlab = "Number of PCs",
     ylab = "Cumulative explained variance")
abline(h = 0.8, col = "red", lty = 2)
abline(h = 0.9, col = "blue", lty = 2)
# elbow plot
cum_var <- cumsum(var_ratio)

plot(var_ratio,
     type = "b",
     pch = 16,
     xlab = "Principal Component",
     ylab = "Proportion of Variance Explained")
# 二阶差分（实用）
d1 <- diff(var_ratio)
d2 <- diff(d1)

plot(d2[1:50], type = "h")


# 02 提取PC score并确定分组###
pc1_pca<-PCcom1$x %>% as.data.frame(.) %>% 
  rownames_to_column(var = "ncell") 

pc1_pca <- left_join(
  PCmeta %>% select(-cell),
  pc1_pca,
  by = 'ncell'
) %>%
  rename(X1 = PC1,
         X2 = PC2)

pc1_pca$cancer <-factor(pc1_pca$cancer)
pc1_pca$depth <- as.numeric(pc1_pca$depth)

# ---------- 03 plotting
summ<-summary(PCcom1)
xlab<-paste0("PC1 (",round(summ$importance[2,1]*100,2),"%)")
ylab<-paste0("PC2 (",sprintf("%0.2f", summ$importance[2,2]*100),"%)")
g <- guide_legend("cancer")
set1 <- RColorBrewer::brewer.pal(11, "Paired") 
gradient_colors <- colorRampPalette(set1)(34) #%>% rev()

#-------------- 05 kmeans
set.seed(123) 

kmeans_result <- kmeans(pc1_pca[8:28],center=5)
pc1_pca['kmeans']=kmeans_result$cluster
pc1_pca$kmeans <- factor(pc1_pca$kmeans,levels=c(1:5))
write.table(pc1_pca,'/cluster2/home/futing/Project/panCancer/Analysis/QC/PC/results/PC1_PCA_1218_top1w.txt',sep='\t',row.names =F,quote=F)


# ----- 05 plot kmeans

source('/cluster2/home/futing/Project/panCancer/Analysis/plot_function.R')
set1 <- RColorBrewer::brewer.pal(11, "Paired") 
gradient_colors <- colorRampPalette(set1)(34) #%>% rev()

pc1_pca$logdepth = log(pc1_pca$depth+1)
pcacancer <- plot_umap_fill(pc1_pca,"cancer","Cancers",xlab=xlab,ylab=ylab,colors = gradient_colors,legendexist=F)
pcacancer
pcadepth <- plot_umap_fill(pc1_pca,"logdepth","Depth",xlab=xlab,ylab=ylab,fill=T,legendexist=F)
pcadepth
pcakmeans <- plot_umap_fill(pc1_pca,"kmeans","Clusters",xlab=xlab,ylab=ylab,legendexist=F)
pcakmeans
pcaorigin <- plot_umap_fill(pc1_pca, "Origin", "Origin",legendexist=F,colors = gradient_colors2)
pcaorigin
pcaCancerCate <- plot_umap_fill(pc1_pca, "Cancer_Category", "Cancer Categories",legendexist=F,colors = gradient_colors2)
pcaCancerCate

pcakmeans_legend <- plot_legend(pc1_pca,'kmeans',"Clusters")
pcaorigin_legend <- plot_legend(pc1_pca,'Origin',"Origin",gradient_colors2)
pcacancer_legend <- plot_legend(pc1_pca,'cancer',"Cancers",gradient_colors)
pcadepth_legend <- plot_legend(pc1_pca,"logdepth","Depth",fill=T)
pcacancertypes_legend <- plot_legend(pc1_pca,'Cancer_Category','Cancer Categories')

# ggsave("/cluster2/home/futing/Project/panCancer/Analysis/QC/PC/plot/1211/PCAPC1_top1w.pdf", egg::set_panel_size(p2, width=unit(3, "in"), height=unit(3, "in")), 
#        width = 8, height = 6, units = 'in')

# --- merge all the plots
# --------- 3 plots
lay = rbind(c(1,1,2,2,3))
#lay <- matrix(c(1, 1, 2), nrow = 1, byrow = TRUE)
grid.arrange(p2,pcacancer, pcakmeans,arrangeGrob(pcakmeans_legend,pcacancer_legend,ncol = 1, nrow =2),layout_matrix = lay,padding = unit(0.01, "cm"))
# ------ 4 plots
lay <- rbind(c(1,1,2,2,3,3,4,4))
# 构建 legend 区域：
# 左边为 pcacancer_legend
# 右边为上下排列的 pcadepth_legend 和 pcakmeans_legend
legend_block <- arrangeGrob(
  pcacancer_legend,
  arrangeGrob(pcadepth_legend, pcakmeans_legend, ncol = 1),
  ncol = 2,
  widths = c(1, 1)
)

# 最终组合
pca_PC_combined <- grid.arrange(pcancer,pcadepth,pcakmeans,
  legend_block,
  layout_matrix = lay,
  padding = unit(0.01, "cm")
)
ggsave("/cluster2/home/futing/Project/panCancer/Analysis/QC/PC/plot/1211/PCPC1_combined_UMAP.pdf", pca_combined,
       width = 18, height = 5, units = 'in')

# ------------- 5 plots
legend_col1 <- arrangeGrob(pcacancer_legend,ncol = 1)

legend_col2 <- arrangeGrob(
  pcadepth_legend,
  pcakmeans_legend,
  pcacancertypes_legend,
  pcaorigin_legend,
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
  pcacancer, pcadepth,
  pcakmeans, pcaCancerCate,
  pcaorigin,
  ncol = 2
)

# --- Layout matrix ---
lay <- rbind(
  c(1, 1, 2),
  c(1, 1, 2),
  c(1, 1, 2)
)

# --- Final arrange ---
PCA_PC_plot<- grid.arrange(
  left_block,
  right_block,
  layout_matrix = lay,
  padding = unit(0.01, "cm")
)

ggsave("/cluster2/home/futing/Project/panCancer/Analysis/QC/PC/plot/1219/PC_combined_kmeans_5_1219_PCA.pdf", PCA_PC_plot, width = 12, height = 10)


#==========================================================
#---- 添加label
#prb <- 
  ggplot(pc1_pca, aes(x=PC1,y = PC2,fill=kmeans)) +
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
  ggrepel::geom_label_repel(aes(label=sample),pc1_pca,
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