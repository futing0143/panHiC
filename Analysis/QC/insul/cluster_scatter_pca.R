pacman::p_load(FactoMineR,ggplot2,magrittr,RColorBrewer,knitr,reshape2,extrafont,ggpubr,gridExtra,tibble)
# Import fonts from the system
font_import()
loadfonts()
par(family = "Arial")


# -------------------------- 01 read in processed data
meta =read.csv('/cluster2/home/futing/Project/panCancer/check/hic/insul0910.txt',sep='\t',check.names = F,header=F)
insul=read.csv('/cluster2/home/futing/Project/panCancer/QC/insul/cancer_327.bed',sep=',')

# --- 预处理
# 按照E1的方差排序，选择最前面的
# fil <- as.integer(0.2 * length(data_var))
# top_var_indices <- order(data_var, decreasing = TRUE)[1:(fil + 1)] # order 返回的是按顺序的索引

rownames(insul) = paste0('insul_',c(1:617669))
df_clean <- insul %>%
  as_tibble() %>%  
  dplyr::select(-chrom, -start, -end) %>%
  # na.omit(axis=1)
  filter(rowSums(is.na(.)) / ncol(.) <= 0.5) #  533153,327
# 

top_features <- order(apply(df_clean, 1, var, na.rm = TRUE), 
                      decreasing = TRUE)[1:10000]
# df_filtered[, apply(df_filtered, 1, var, na.rm = TRUE) > 0] #去掉全是NA的
df <- df_clean[top_features,] %>% t() %>%
  replace(., is.na(.), 0)
# df <- replace(df_clean, is.na(df_clean), 0)
#--------------------------- 02 running PCA
#d1log2 <- log(d1,2)
#pc1_fil0<- scale(pc1_fil0,center=T,scale=T)

# method 1
library(missMDA)

# 首先对缺失值进行插补
df_imputed <- imputePCA(df, ncp = 5, scale = TRUE)$completeObs
# 然后在插补后的数据上进行PCA分析
com1 <- PCA(df_imputed, scale.unit = TRUE, ncp = 5, graph = FALSE)
com1 <- PCA(df, scale.unit = TRUE, ncp = 5, graph = FALSE)

# method2 
com1 <- prcomp(df, center = T,scale = TRUE)

# 02 提取PC score并确定分组###
pc1_pca<-com1$x %>% as.data.frame(.) %>% 
  rownames_to_column(var = "ncell") 

pc1_pca =merge(pc1_pca,meta[,c(1,4)],by='ncell')
pc1_pca$cancer <-factor(pc1_pca$cancer)
write.table(pc1_pca,'/cluster2/home/futing/Project/panCancer/Analysis/QC/insul/PCAinsul327_top1w.txt',sep='\t',row.names =F)

summ<-summary(com1)
xlab<-paste0("PC1 (",round(summ$importance[2,1]*100,2),"%)")
ylab<-paste0("PC2 (",sprintf("%0.2f", summ$importance[2,2]*100),"%)")
g <- guide_legend("cancer")
set1 <- RColorBrewer::brewer.pal(11, "Paired") 
gradient_colors <- colorRampPalette(set1)(32) #%>% rev()
# pc1_pcafil <- pc1_pca %>% filter(PC1<2000)
pc1_pcafil <- pc1_pca %>% filter(PC1<500,PC2<40)

# ------ PCA plot
p2<-
  ggplot(data = pc1_pcafil,aes(x=PC1,y=PC2,fill=cancer))+
  #散点图  
  #stat_ellipse(aes(fill=dataset),type = "norm", geom ="polygon",alpha=0.2,color=NA)+
  geom_point(stroke=0.35,shape=21,size=2,color="black",alpha=0.8)+
  scale_fill_manual(values=gradient_colors)+
  #scale_color_brewer(palette = 'Set1')+
  # scale_fill_manual(values=c('#a6cee3','#33a02c','#b2df8a','#1f78b4','#e31a1c','#fb9a99','#fdbf6f'))+
  labs(x=xlab,y=ylab,color="cancer")+
  ggtitle("Cancer")+
  guides(fill=g,size=g,color=g,shape=g)+
  theme_bw()+
  theme(plot.title = element_text(size=12, face="bold",hjust=0.5,family="sans"),
        plot.background = element_rect(fill = NA, colour = NA),
        axis.title= element_text(vjust=0.5,hjust=0.5,family = "sans",size=10),
        axis.text = element_text(colour="black", size=9,family = "sans"),
        axis.ticks = element_line(colour="black"),
        axis.line = element_line(colour = "black",linewidth =0.4),
        panel.border = element_rect(fill=NA,color=NA,linetype = 1),
        panel.grid=element_blank(),#去掉背景线
        legend.title = element_blank(),
        legend.text =element_text(size=10,family = "sans"),
        legend.background = element_rect(fill = "transparent", colour = NA),
        # legend.position = "none",
        legend.margin = margin(t = 0, r = 1, b = 0, l = 0, unit = "pt"),
        ###图周围的边距
        plot.margin = unit(c(0.5,0.5,0.5,0.5),"cm"))
p2
ggsave("/cluster2/home/futing/Project/panCancer/Analysis/QC/insul/plot/PCAinsul327_stop1w_fil.pdf", egg::set_panel_size(p2, width=unit(3, "in"), height=unit(3, "in")), 
       width = 8, height = 6, units = 'in')

#-------------- 05 kmeans
set.seed(123) 
pca_result = pc1_pcafil
kmeans_result <- kmeans(pca_result[2:22],center=5)
pca_result['kmeans']=kmeans_result$cluster
#pc1_pca$kmeans <- ifelse(pc1_pca$kmeans == 3, 1, ifelse(pc1_pca$kmeans == 1, 3, pc1_pca$kmeans))
pca_result$kmeans <- factor(pca_result$kmeans,levels=c(1:5))

# ----- 05 plot kmeans
set1 <- RColorBrewer::brewer.pal(11, "Paired") 
gradient_colors <- colorRampPalette(set1)(32) #%>% rev()

pcacancer<-
  ggplot(data = pca_result,aes(x=PC1,y=PC2,fill=cancer))+
  #散点图  
  #stat_ellipse(aes(fill=dataset),type = "norm", geom ="polygon",alpha=0.2,color=NA)+
  geom_point(stroke=0.35,shape=21,size=2,color="black",alpha=0.8)+
  scale_fill_manual(values=gradient_colors)+
  #scale_color_brewer(palette = 'Set1')+
  labs(x=xlab,y=ylab,color="")+
  ggtitle("Cancers")+
  guides(fill=g,size=g,color=g,shape=g)+
  theme_bw()+
  theme(plot.title = element_text(size=12, face="bold",hjust=0.5,family="sans"),
        plot.background = element_rect(fill = NA, colour = NA),
        axis.title= element_text(vjust=0.5,hjust=0.5,family = "sans",size=10),
        axis.text = element_text(colour="black", size=9,family = "sans"),
        axis.ticks = element_line(colour="black"),
        axis.line = element_line(colour = "black",linewidth =0.4),
        panel.border = element_rect(fill=NA,color=NA,linetype = 1),
        panel.grid=element_blank(),#去掉背景线
        legend.title = element_blank(),
        legend.text =element_text(size=10,family = "sans"),
        legend.background = element_rect(fill = "transparent", colour = NA),
        legend.position = "none",
        legend.margin = margin(t = 0, r = 1, b = 0, l = 0, unit = "pt"),
        ###图周围的边距
        plot.margin = unit(c(0.5,0.5,0.5,0.5),"cm"))
pcacancer


pcakmeans =   ggplot(data = pca_result,aes(x=PC1,y=PC2,fill=kmeans))+
  #stat_ellipse(aes(fill=dataset),type = "norm", geom ="polygon",alpha=0.2,color=NA)+
  geom_point(stroke=0.35,shape=21,size=2,color="black",alpha=0.8)+
  scale_fill_brewer(palette = 'Dark2')+
  labs(x=xlab,y=ylab,fill="Clusters")+
  ggtitle("Clusters")+
  guides(fill=g,size=g,color=g,shape=g)+
  theme_bw()+
  theme(plot.title = element_text(size=12, face="bold",hjust=0.5,family="sans"),
        plot.background = element_rect(fill = NA, colour = NA),
        axis.title= element_text(vjust=0.5,hjust=0.5,family = "sans",size=10),
        axis.text = element_text(colour="black", size=9,family = "sans"),
        axis.ticks = element_line(colour="black"),
        axis.line = element_line(colour = "black",linewidth =0.4),
        panel.border = element_rect(fill=NA,color=NA,linetype = 1),
        panel.grid=element_blank(),#去掉背景线
        legend.title = element_blank(),
        legend.text =element_text(size=10,family = "sans"),
        legend.background = element_rect(fill = "transparent", colour = NA),
        legend.position = "none",
        legend.margin = margin(t = 0, r = 1, b = 0, l = 0, unit = "pt"),
        ###图周围的边距
        plot.margin = unit(c(0.5,0.5,0.5,0.5),"cm"))
pcakmeans

# 额外添加legend
pcakmeans_legend <- get_legend(
  ggplot(data = pc1_pca,aes(x=PC1,y=PC2,fill=kmeans)) +
    geom_point(stroke=0.35,size=3,alpha=0.8,shape=21,color="black")+
    scale_fill_brewer(palette = 'Dark2')+ 
    labs(fill="Clusters")+
    theme_bw()+
    theme(legend.position = "right",
          legend.text =element_text(size=10,family = "sans"),
          legend.background = element_rect(fill =NA, colour = NA),
          legend.margin = margin(t = 0, r = 0, b = 0, l = 0, unit = "pt")))
pcacancer_legend <- get_legend(
  ggplot(data = pc1_pca,aes(x=PC1,y=PC2,fill=cancer)) +
    geom_point(stroke=0.35,size=3,alpha=0.8,shape=21,color="black")+
    scale_fill_manual(values=gradient_colors)+
    labs(fill="Cancers")+
    theme_bw()+
    theme(legend.position = "right",
          legend.text =element_text(size=10,family = "sans"),
          legend.background = element_rect(fill =NA, colour = NA),
          legend.margin = margin(t = 0, r = 0, b = 0, l = 0, unit = "pt")))
# pca_legend <- get_legend(
#   ggplot(data = pc1_pca,aes(x=PC1,y=PC2,fill=cancer))+
#   geom_point(stroke=0.35,shape=21,size=3,color="black",alpha=0.8)+
#   labs(fill='Dataset')+
#   scale_fill_manual(values=c('#a6cee3','#33a02c','#b2df8a','#1f78b4','#e31a1c','#fb9a99','#fdbf6f'))+
#     theme_bw()+
#   theme(
#     legend.text =element_text(size=10,family = "sans"),
#     legend.background = element_rect(fill = NA, colour = NA),
#     legend.position = "right",
#     legend.margin = margin(t = 0, r = 0, b = 0, l = 0, unit = "pt")))

# --- merge all the plots

lay = rbind(c(1,1,2,2,3))
#lay <- matrix(c(1, 1, 2), nrow = 1, byrow = TRUE)
grid.arrange(p2,pcacancer, pcakmeans,arrangeGrob(pcakmeans_legend,pcacancer_legend,ncol = 1, nrow =2),layout_matrix = lay,padding = unit(0.01, "cm"))

lay = rbind(c(1, 1,2,2,3,3))
#lay <- matrix(c(1, 1, 2), nrow = 1, byrow = TRUE)
grid.arrange(pcacancer, pcakmeans,arrangeGrob(pcacancer_legend,pcakmeans_legend,ncol = 2, nrow =1), layout_matrix = lay,padding = unit(0.01, "cm"))


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