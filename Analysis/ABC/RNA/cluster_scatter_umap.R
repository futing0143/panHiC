pacman::p_load(readxl,magrittr,ggplot2,egg,ggpubr,janitor,gridExtra,reshape2,extrafont,RColorBrewer,dplyr,stringr)
# Import fonts from the system
font_import()
loadfonts()
par(family = "Arial")
setwd('/cluster2/home/futing/Project/panCancer/Analysis/QC/PC')

# -------------------------- 01 read in processed data
meta =read.csv('/cluster2/home/futing/Project/panCancer/check/hic/insul0910.txt',sep='\t',check.names = F,header=F)
data=t(df_clean)# 来源于 pca
# 按照E1的方差排序，选择最前面的
data_var <- apply(data, 2, var)
fil <- as.integer(0.2 * length(data_var))
top_var_indices <- order(data_var, decreasing = TRUE)[1:(fil + 1)] # order 返回的是按顺序的索引
data_fil=pc1[,top_var_indices]

#--------------------------- 02 running PCA
#d1log2 <- log(d1,2)
#standardize#
# pc1_fil0<- scale(pc1_fil0,center=T,scale=T)
com1 <- prcomp(df, center = T,scale = TRUE)

#----------------- umap
library(umap)
pcdata=com1$x %>% as.data.frame(.)
iris.umap = umap::umap(pcdata[1:15],
                       n_neighbors = 20,  # 设置邻居数
                       min_dist = 0.1,    # 设置最小距离
                       metric = "euclidean")
PC1umap=data.frame(iris.umap$layout)
PC1umap$ncell =rownames(PC1umap)
PC1umap=merge(PC1umap,meta,by.x='ncell',by.y='header')
head(PC1umap)
# PC1umap$dataset <-factor(PC1umap$dataset,ordered=T,levels = c("Chen et al","Cheng et al","Johnson et al","Mathur et al","Xie et al","Xu et al","unpublished"))
write.table(PC1umap,"/cluster2/home/futing/Project/panCancer/Analysis/QC/PC/plot/UMAPPC1_359_top1w.txt",sep="\t",row.names = F)

puma = ggplot(data = PC1umap,aes(x=X1,y=X2,fill=Datasource))+
  #散点图  
  geom_point(stroke=0.35,shape=21,size=2,color="black",alpha=0.8)+
  scale_fill_brewer(palette = 'Set1')+
  #scale_color_brewer(palette = 'Set1')+
  # scale_fill_manual(values=gradient_colors)+
  labs(x="UMAP1",y="UMAP2",color="black")+
  ggtitle("Datasource")+
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
        plot.margin = unit(c(0.5,0.5,0,0.5),"cm"))

puma
ggsave("TPMdatasource_UMAP.pdf", egg::set_panel_size(puma, width=unit(3, "in"), height=unit(3, "in")),
     width = 8, height = 6, units = 'in')

#-------------- 05 kmeans
set.seed(123) 

# umap
kmeans_result <-kmeans(PC1umap[,2:3],centers = 4,nstart=100,iter.max = 1000)
PC1umap['kmeans']=kmeans_result$cluster
PC1umap$kmeans = factor(PC1umap$kmeans,levels=c(1:4))

# compare umap and pca results
compare=merge(PC1umap[,c(1,ncol(PC1umap))],pca_result[,c(1,ncol(pca_result))],by='ncell')
write.table(compare,"./compare_TPM1203.txt",sep="\t",row.names = F)


pukmeans = ggplot(data = PC1umap,aes(x=X1,y=X2,fill=kmeans))+
  #散点图  
  geom_point(stroke=0.35,size=2,alpha=0.8,shape=21,color="black")+
  scale_fill_brewer(palette = 'Set1')+
  #scale_color_brewer(palette = 'Set1')+
  #scale_fill_manual(values=c('#a6cee3','#33a02c','#b2df8a','#1f78b4','#e31a1c','#fb9a99','#fdbf6f'))+
  labs(x="UMAP1",y="UMAP2",fill="Clusters")+
  ggtitle("Clusters")+
  theme_bw()+
  theme(plot.title = element_text(size=12, face="bold",hjust=0.5,family="sans"),
        plot.background = element_rect(fill = NA, colour = NA),
        axis.title= element_text(vjust=0.5,hjust=0.5,family = "sans",size=10),
        axis.text = element_text(colour="black", size=9,family = "sans"),
        axis.ticks = element_line(colour="black"),
        axis.line = element_line(colour = "black",linewidth =0.4),
        panel.border = element_rect(fill=NA,color=NA,linetype = 1),
        panel.grid=element_blank(),#去掉背景线
        legend.text =element_text(size=10,family = "sans"),
        legend.background = element_rect(fill = "transparent", colour = NA),
        # legend.position = "none",
        legend.margin = margin(t = 0, r = 1, b = 0, l = 0, unit = "pt"),
        plot.margin = unit(c(0.5,0.5,0,0.5),"cm"))        ###图周围的边距
pukmeans

pusource = ggplot(data = PC1umap,aes(x=X1,y=X2,fill=Datasource))+
  geom_point(stroke=0.35,size=2,alpha=0.8,shape=21,color="black")+
  scale_fill_brewer(palette = 'Set1')+
  # scale_fill_gradient(low='white', high = "darkblue", name = "Depth") +
  ggtitle("Data Source")+
  guides(fill = guide_colorbar(),size=g,color=g,shape=g)+
  labs(x="UMAP1",y="UMAP2")+
  theme_bw()+
  theme(plot.title = element_text(size=12, face="bold",hjust=0.5,family="sans"),
        plot.background = element_rect(fill = NA, colour = NA),
        axis.title= element_text(vjust=0.5,hjust=0.5,family = "sans",size=10),
        axis.text = element_text(colour="black", size=9,family = "sans"),
        axis.ticks = element_line(colour="black"),
        axis.line = element_line(colour = "black",linewidth =0.4),
        panel.border = element_rect(fill=NA,color=NA,linetype = 1),
        panel.grid=element_blank(),#去掉背景线
        legend.text =element_text(size=10,family = "sans"),
        legend.background = element_rect(fill = "transparent", colour = NA),
        legend.position = "none",
        legend.margin = margin(t = 0, r = 1, b = 0, l = 0, unit = "pt"),
        plot.margin = unit(c(0.5,0.5,0,0.5),"cm"))        ###图周围的边距
pusource


#--- move the legend to the right
pukmeans_legend <- get_legend(
  ggplot(data = PC1umap,aes(x=X1,y=X2,fill=kmeans)) +
    geom_point(stroke=0.35,size=3,alpha=0.8,shape=21,color="black")+
    scale_fill_brewer(palette = 'Dark2')+ 
    labs(fill="Clusters")+
    theme_bw()+
    theme(legend.position = "right",
          legend.text =element_text(size=10,family = "sans"),
          legend.background = element_rect(fill =NA, colour = NA),
          legend.margin = margin(t = 0, r = 0, b = 0, l = 0, unit = "pt")))
puma_legend <- get_legend(
  ggplot(data = PC1umap,aes(x=X1,y=X2,fill=cancer)) +
    geom_point(stroke=0.35,size=3,alpha=0.8,shape=21,color="black")+
    scale_fill_manual(values=gradient_colors)+
    labs(fill="Cancers")+
    theme_bw()+
    theme(legend.position = "right",
          legend.text =element_text(size=10,family = "sans"),
          legend.background = element_rect(fill =NA, colour = NA),
          legend.margin = margin(t = 0, r = 0, b = 0, l = 0, unit = "pt")))

pudepth_legend <- get_legend(
  ggplot(data = PC1umap,aes(x=X1,y=X2,fill=Datasource))+
    geom_point(stroke=0.35,shape=21,size=3,color="black",alpha=0.8)+
    labs(fill='Data Source')+
    guides(fill = g,size=g,color=g,shape=g)+
    # scale_fill_gradient(low='white', high = "darkblue", name = "Depth") +
    theme_bw()+
    theme(
      legend.text =element_text(size=10,family = "sans"),
      legend.background = element_rect(fill = NA, colour = NA),
      legend.position = "right",
      legend.margin = margin(t = 0, r = 0, b = 0, l = 0, unit = "pt")))

# ------- merge all the plots
lay = rbind(c(1, 1,2,2,3,4))
#lay <- matrix(c(1, 1, 2), nrow = 1, byrow = TRUE)
grid.arrange(puma, pukmeans,pukmeans_legend,puma_legend, layout_matrix = lay,padding = unit(0.01, "cm"))

lay <- rbind(c(1,1,2,2,3,3,4,4))
# 构建 legend 区域：
# 左边为 pcacancer_legend
# 右边为上下排列的 pcadepth_legend 和 pcakmeans_legend
legend_block <- arrangeGrob(
  puma_legend,
  arrangeGrob(pudepth_legend, pukmeans_legend, ncol = 1),
  ncol = 2,
  widths = c(1, 1)
)

# 最终组合
grid.arrange(puma,pudepth,pukmeans,
             legend_block,
             layout_matrix = lay,
             padding = unit(0.01, "cm")
)



# ----- 05 看组别
head(PC1umap)
dat <- PC1umap %>%
  count(cancer, kmeans) %>%  # 计算每个cancer-kmeans组合的计数
  group_by(cancer) %>%
  mutate(
    Total = sum(n),
    Percent = n / Total 
  ) %>%
  ungroup()

dat$kmeans = factor(dat$kmeans)
kmeans_colors <- colorRampPalette(c("#D64F38","#F8F2ED","#77A3BB","#16365F"))(5)
p <- 
ggplot(dat, aes(x = cancer, y = Percent, fill = kmeans)) +
  geom_col(position = "stack") +
  scale_fill_manual(values=kmeans_colors)+
  labs(title = "Kmeans cluster",
       x = "",
       y = "Proportion",
       fill = "Category") +
  scale_y_continuous(labels = percent_format(accuracy = 0.01)) +  # 两位小数
  theme_bw()+
  theme(plot.title = element_text(size=12, face="bold",hjust=0.5,family="sans"),
        plot.background = element_rect(fill = NA, colour = NA),
        axis.title= element_text(vjust=0.5,hjust=0.5,family = "sans",size=10),
        axis.text.y = element_text(colour="black", size=9,family = "sans"),
        axis.text.x = element_text(size=8,angle = 60, hjust = 1),
        axis.ticks = element_line(colour="black"),
        axis.line = element_line(colour = "black",linewidth =0.4),
        panel.border = element_rect(fill=NA,color=NA,linetype = 1),
        panel.grid=element_blank(),#去掉背景线
        # legend.title = element_blank(),
        legend.text =element_text(size=10,family = "sans"),
        legend.background = element_rect(fill = "transparent", colour = NA),
        # legend.position = "none",
        legend.margin = margin(t = 0, r = 1, b = 0, l = 0, unit = "pt"),
        ###图周围的边距
        plot.margin = unit(c(0.5,0.5,0.5,0.5),"cm"))
ggsave("Umap proportion.pdf", egg::set_panel_size(p, width=unit(6, "in"), height=unit(3, "in")), 
       width = 10, height = 6, units = 'in')

#---- 添加label
labeldata=PC1umap[PC1umap$ncell %in% compare[compare$kmeans.x != compare$kmeans.y,]$ncell,]
prb <- 
ggplot(PC1umap, aes(x=X1,y = X2,fill=kmeans)) +
  geom_point(stroke=0.35,shape=21,size=2,color="black",alpha=0.8)+
  labs(x="UMAP1",y="UMAP2",fill="Dataset")+
  scale_fill_brewer(palette = 'Dark2')+ 
  #geom_smooth(formula=y~x,color="red",method = lm,se=FALSE)+
  #annotate('text',x=0.75,y=-0.8,label=paste("R =",cor_GH,sep = " "),size=4,fontface="bold")+####系数和坐标要修改
  #scale_x_continuous(expand=c(0,0),limits=c(-1.2,1.2))+
  #scale_y_continuous(expand=c(0,0),limits = c(-1.2,1.2))+
  theme_bw()+####去掉灰色背景
  theme(plot.title = element_text(hjust=0.5,size=12, face=2,family="sans"),
        plot.background = element_rect(fill = NA, colour = NA),####去掉绘图背景
        axis.title = element_text(family = "sans",size=12),
        axis.text.x =  element_text(colour="black", size=11),
        axis.text.y =  element_text(colour="black", size=11),
        axis.ticks = element_line(colour="black",linewidth = 0.5),
        axis.line = element_blank(),
        panel.border = element_rect(fill=NA,color="black",linewidth = 1,linetype = 1),
        panel.grid = element_blank(),###去掉网格线
        legend.position = "right")+ # +
  ggrepel::geom_label_repel(aes(label=ncell),PC1umap,
                            size = 2, #注释文本的字体大小
                            box.padding = 0.3, #字到点的距离
                            point.padding = 0.5, #字到点的距离，点周围的空白宽度
                            min.segment.length = 0.1, #短于某长度隐藏
                            segment.color = "black", #segment.colour = NA, 不显示线段
                            show.legend = F,
                            fill=NA,
                            max.overlaps = getOption("ggrepel.max.overlaps", default = 50))
prb
ggsave("Cor_GH.pdf", egg::set_panel_size(prb, width=unit(4.5, "in"), height=unit(4.5, "in")), 
       width = 10, height = 8, units = 'in')
