library(ggplot2)
library(magrittr)
library(RColorBrewer)
library(knitr)#melt
library(reshape2)
library(extrafont)
library(ggpubr)
library(gridExtra)
# Import fonts from the system
font_import()
loadfonts()t
par(family = "Arial")

pc1=read.csv('/cluster/home/futing/Project/GBM/HiC/06compartment/cooltools/E1_100k_norm.tsv',sep='\t')
pc1 <- pc1[, !(colnames(pc1) %in% c('GBM', 'OPC', 'astro1', 'astro2', 'ipsc', 
                                    'NPC', 'pHGG', 'iPSC_new', 'NPC_new', 
                                    'GB176', 'GB180', 'GB182', 'GB183', 'GB238'))]

E1_var <- apply(pc1, 1, var)
fil <- as.integer(0.2 * length(E1_var))
top_var_indices <- order(E1_var, decreasing = TRUE)[1:(fil + 1)] # order 返回的是按顺序的索引
pc1_fil=pc1[top_var_indices,]


# -------------------------- 01 read in processed data
pc1_fil=read.csv('/cluster/home/futing/Project/GBM/HiC/09insulation/00plot/PC1/E1_down_100k_fil0.2.txt',sep=',')
rownames(pc1_fil)=pc1_fil[,1]
pc1_fil=pc1_fil[,-1]
subtype=read.csv('/cluster/home/futing/Project/GBM/HiC/09insulation/meta_GBM.txt',sep='\t')
pc1_fil=t(pc1_fil)
pc1_fil0 <- replace(pc1_fil, is.na(pc1_fil), 0)

#--------------------------- 02 running PCA
#d1log2 <- log(d1,2)
#standardize#
#pc1_fil0<- scale(pc1_fil0,center=T,scale=T)
com1 <- prcomp(pc1_fil0, center = T,scale = TRUE)

###提取PC score并确定分组###
pc1_pca<-com1$x %>% as.data.frame(.)
pc1_pca$sample=rownames(pc1_pca)
pc1_pca$sample[c(1,45,46,47)]=c("42MGBA","P529.SF12794v1-1","P529.SF12794v6-1","P529.SF12794v8-1")
pc1_pca =merge(pc1_pca,subtype,by='sample')
pc1_pca$subtype <-factor(pc1_pca$subtype,ordered=TRUE,levels=c("Mesenchymal","Proneural","Neural","Classical","Unknown")) #修改因子水平 
pc1_pca$dataset <-factor(pc1_pca$dataset,ordered=T,levels = c("Chen et al","Cheng et al","Johnson et al","Mathur et al","Xie et al","Xu et al","unpublished"))
write.table(pc1_pca,'/cluster/home/futing/Project/GBM/HiC/09insulation/00plot/PC1/scatter/PC1_R_Kmeans.txt',sep='\t',row.names =F)

summ<-summary(com1)
xlab<-paste0("PC1 (",round(summ$importance[2,1]*100,2),"%)")
ylab<-paste0("PC2 (",sprintf("%0.2f", summ$importance[2,2]*100),"%)")
g <- guide_legend("subtype")
p2<-
  ggplot(data = pc1_pca,aes(x=PC1,y=PC2,fill=dataset))+
  #散点图  
  #stat_ellipse(aes(fill=dataset),type = "norm", geom ="polygon",alpha=0.2,color=NA)+
  geom_point(stroke=0.35,shape=21,size=2,color="black",alpha=0.8)+
  #scale_fill_brewer(palette = 'Set1')+
  #scale_color_brewer(palette = 'Set1')+
  scale_fill_manual(values=c('#a6cee3','#33a02c','#b2df8a','#1f78b4','#e31a1c','#fb9a99','#fdbf6f'))+
  labs(x=xlab,y=ylab,color="Dataset")+
  ggtitle("Datasets")+
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
p2
ggsave("/cluster/home/futing/Project/GBM/HiC/09insulation/00plot/PC1/PCA1_fil.pdf", egg::set_panel_size(p2, width=unit(3, "in"), height=unit(3, "in")), 
       width = 8, height = 6, units = 'in')

#-------------- 05 kmeans
set.seed(123) 
# pca
kmeans_result <- kmeans(pc1_pca[2:22], centers = 3)
pc1_pca['kmeans']=kmeans_result$cluster
#pc1_pca$kmeans <- ifelse(pc1_pca$kmeans == 3, 1, ifelse(pc1_pca$kmeans == 1, 3, pc1_pca$kmeans))
pc1_pca$kmeans<-factor(pc1_pca$kmeans,levels=c(1,2,3))

pcasubtype<-
  ggplot(data = pc1_pca,aes(x=PC1,y=PC2,fill=subtype))+
  #散点图  
  #stat_ellipse(aes(fill=dataset),type = "norm", geom ="polygon",alpha=0.2,color=NA)+
  geom_point(stroke=0.35,shape=21,size=2,color="black",alpha=0.8)+
  scale_fill_brewer(palette = 'Set1')+
  #scale_color_brewer(palette = 'Set1')+
  labs(x=xlab,y=ylab,color="")+
  ggtitle("TCGA subtypes")+
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
pcasubtype


pcakmeans =   ggplot(data = pc1_pca,aes(x=PC1,y=PC2,fill=kmeans))+
  #stat_ellipse(aes(fill=dataset),type = "norm", geom ="polygon",alpha=0.2,color=NA)+
  geom_point(stroke=0.35,shape=21,size=2,color="black",alpha=0.8)+
  scale_fill_brewer(palette = 'Dark2')+
  #scale_color_brewer(palette = 'Set1')+
  #scale_fill_manual(values=c('#a6cee3','#33a02c','#b2df8a','#1f78b4','#e31a1c','#fb9a99','#fdbf6f'))+
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
pcasubtype_legend <- get_legend(
  ggplot(data = pc1_pca,aes(x=PC1,y=PC2,fill=subtype)) +
    geom_point(stroke=0.35,size=3,alpha=0.8,shape=21,color="black")+
    scale_fill_brewer(palette = 'Set1')+ 
    labs(fill="Clusters")+
    theme_bw()+
    theme(legend.position = "right",
          legend.text =element_text(size=10,family = "sans"),
          legend.background = element_rect(fill =NA, colour = NA),
          legend.margin = margin(t = 0, r = 0, b = 0, l = 0, unit = "pt")))

pca_legend <- get_legend(
  ggplot(data = pc1_pca,aes(x=PC1,y=PC2,fill=dataset))+
  geom_point(stroke=0.35,shape=21,size=3,color="black",alpha=0.8)+
  labs(fill='Dataset')+
  scale_fill_manual(values=c('#a6cee3','#33a02c','#b2df8a','#1f78b4','#e31a1c','#fb9a99','#fdbf6f'))+
    theme_bw()+
  theme(
    legend.text =element_text(size=10,family = "sans"),
    legend.background = element_rect(fill = NA, colour = NA),
    legend.position = "right",
    legend.margin = margin(t = 0, r = 0, b = 0, l = 0, unit = "pt")))

# --- merge all the plots

lay = rbind(c(1,1,2,2,3,3,4,5))
#lay <- matrix(c(1, 1, 2), nrow = 1, byrow = TRUE)
grid.arrange(p2,pcasubtype, pcakmeans,arrangeGrob(pcakmeans_legend,pcasubtype_legend,ncol = 1, nrow =2),pca_legend, layout_matrix = lay,padding = unit(0.01, "cm"))

lay = rbind(c(1, 1,2,2,3,3))
#lay <- matrix(c(1, 1, 2), nrow = 1, byrow = TRUE)
grid.arrange(p2, pcakmeans,arrangeGrob(pca_legend,pcakmeans_legend,ncol = 2, nrow =1), layout_matrix = lay,padding = unit(0.01, "cm"))


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