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
com1 <- prcomp(df, center = T,scale = TRUE)

#----------------- umap
library(umap)
pcdata=com1$x %>% as.data.frame(.)
iris.umap = umap::umap(pcdata[1:15],
                       n_neighbors = 20,  # 设置邻居数
                       min_dist = 0.1,    # 设置最小距离
                       metric = "euclidean")
RNAumap=data.frame(iris.umap$layout)
RNAumap$ncell =rownames(RNAumap)
RNAumap=RNAumap[,1:3]
RNAumap=merge(RNAumap,meta,by.x='ncell',by.y='header')
head(RNAumap)
write.table(RNAumap,"/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/results/1211/TPMUMAP_1212_all.txt",
            sep="\t",row.names = F,quote = F)
RNAumap <- read.csv("/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/results/1211/TPMUMAP_1210_all.txt",
                    sep="\t")
#-------------- 05 kmeans
set.seed(123) 

# umap
kmeans_result <-kmeans(RNAumap[,2:3],centers = 5,nstart=100,iter.max = 1000)
RNAumap['kmeans']=kmeans_result$cluster
RNAumap$kmeans = factor(RNAumap$kmeans,levels=c(1:5))

# compare umap and pca results
compare=merge(RNAumap[,c(1,ncol(RNAumap))],pca_result[,c(1,ncol(pca_result))],by.x='ncell',by.y='header')
write.table(compare,"./results/1211/compare_TPM1211.txt",sep="\t",row.names = F)
write.table(RNAumap,"./results/1211/TPMUMAP_1210_all.txt",sep="\t",row.names = F,quote=F)

set1 <- RColorBrewer::brewer.pal(11, "Paired") 
gradient_colors <- colorRampPalette(set1)(37) #%>% rev()
pusource <- plot_umap_fill(RNAumap, "Datasource", "Data Source",legendexist=F)
pusource
pukmeans <- plot_umap_fill(RNAumap, "kmeans", "Clusters",legendexist=F)
pukmeans
p1 <- plot_umap_fill(RNAumap, "cancer", "Cancers",colors=gradient_colors,F)
p1
puCancerCate <- plot_umap_fill(RNAumap, "Cancer_Category", "Cancer Categories",legendexist=F)
puCancerCate
puCancerCate <- plot_umap_fill(RNAumap, "Cancer_Category", "Cancer Categories",legendexist=F)
puCancerCate
ggsave("/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/plot/1211/TPMdatasource_UMAP.pdf", egg::set_panel_size(puma, width=unit(3, "in"), height=unit(3, "in")),
       width = 8, height = 6, units = 'in')

# ----- plot function
plot_umap_fill <- function(df, fill_col, title_text, colors = "brewer", legendexist = TRUE) {
  
  # 颜色设置
  if (identical(colors, "brewer")) {
    color_setting <- scale_fill_brewer(palette = "Set1")
  } else {
    color_setting <- scale_fill_manual(values = colors)
  }
  
  p <- ggplot(data = df, aes(x = X1, y = X2, fill = .data[[fill_col]])) +
    geom_point(stroke = 0.35, size = 2, alpha = 0.8, shape = 21, color = "black") +
    color_setting +
    ggtitle(title_text) +
    guides(fill = g, size = g, color = g, shape = g) +
    labs(x = "UMAP1", y = "UMAP2") +
    theme_bw() +
    theme(
      plot.title = element_text(size = 12, face = "bold", hjust = 0.5, family = "sans"),
      plot.background = element_rect(fill = NA, colour = NA),
      axis.title = element_text(vjust = 0.5, hjust = 0.5, family = "sans", size = 10),
      axis.text = element_text(colour = "black", size = 9, family = "sans"),
      axis.ticks = element_line(colour = "black"),
      axis.line = element_line(colour = "black", linewidth = 0.4),
      panel.border = element_rect(fill = NA, color = NA, linetype = 1),
      panel.grid = element_blank(),
      legend.text = element_text(size = 10, family = "sans"),
      legend.background = element_rect(fill = "transparent", colour = NA),
      legend.margin = margin(t = 0, r = 1, b = 0, l = 0, unit = "pt"),
      legend.title = element_blank(),
      plot.margin = unit(c(0.5, 0.5, 0, 0.5), "cm")
    )
  
  # legend 控制（动态添加 theme）
  if (!legendexist) {
    p <- p + theme(legend.position = "none")
  }
  
  return(p)
}

plot_legend <- function(df,fill_col,title,colors="brewer"){
  if (identical(colors, "brewer")){
    color_setting=scale_fill_brewer(palette = "Set1")
  }else{
    color_setting=scale_fill_manual(values=colors)
  }
  get_legend(
    ggplot(data = df,aes(x=X1,y=X2,fill=.data[[fill_col]])) +
      geom_point(stroke=0.35,size=3,alpha=0.8,shape=21,color="black")+
      color_setting+ 
      labs(fill=title)+
      theme_bw()+
      theme(legend.position = "right",
            legend.text =element_text(size=10,family = "sans"),
            legend.background = element_rect(fill =NA, colour = NA),
            legend.margin = margin(t = 0, r = 0, b = 0, l = 0, unit = "pt")))
}
pukmeans_legend <- plot_legend(RNAumap,'kmeans',"Clusters")
puma_legend <- plot_legend(RNAumap,'cancer',"Cancers",gradient_colors)
pudatasource_legend <- plot_legend(RNAumap,'Datasource','Data Source')
pucancertypes_legend <- plot_legend(RNAumap,'Cancer_Category','Cancer Categories')

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
  arrangeGrob(pudatasource_legend, pukmeans_legend,pucancertypes_legend, ncol = 1),
  ncol = 2,
  widths = c(1, 1)
)

# 最终组合
grid.arrange(p1,pusource,pukmeans,puCancerCate,
             legend_block,
             layout_matrix = lay,
             padding = unit(0.01, "cm")
)

# --- Legend block ---
legend_col1 <- arrangeGrob(puma_legend, ncol = 1)

legend_col2 <- arrangeGrob(
  pudatasource_legend,
  pukmeans_legend,
  pucancertypes_legend,
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
  p1, pusource,
  pukmeans, puCancerCate,
  ncol = 2
)

# --- Layout matrix ---
lay <- rbind(
  c(1, 1, 2),
  c(1, 1, 2)
)

# --- Final arrange ---
combined_plot<- grid.arrange(
  left_block,
  right_block,
  layout_matrix = lay,
  padding = unit(0.01, "cm")
)

ggsave("./plot/1211/TPMUMAP_combined_all.pdf", combined_plot, width = 15, height = 8)

# ----- 05 看组别
head(RNAumap)

plot_proportion <- function(df, vectorx = "kmeans", vector2 = "Cancer_Category",
                            colors = NULL, title_text = "Cancer Category") {
  
  # check columns exist
  if (!(vectorx %in% names(df))) stop("vectorx not in df")
  if (!(vector2 %in% names(df))) stop("vector2 not in df")
  
  # 数据准备：统计比例
  dat <- df %>%
    count(.data[[vector2]], .data[[vectorx]]) %>%
    group_by(.data[[vector2]]) %>%
    mutate(
      Total = sum(n),
      Percent = n / Total
    ) %>%
    ungroup()
  
  # 自动颜色：如未提供 colors，则给 5 个默认色
  if (is.null(colors)) {
    colors <- colorRampPalette(c("#D64F38","#F8F2ED","#77A3BB","#16365F"))(length(unique(dat[[vectorx]])))
  }
  
  dat[[vectorx]] <- factor(dat[[vectorx]])
  
  p <- ggplot(dat, aes(x = .data[[vector2]], y = Percent, fill = .data[[vectorx]])) +
    geom_col(position = "stack") +
    scale_fill_manual(values = colors) +
    labs(
      title = title_text,
      x = "",
      y = "Proportion",
      fill = vectorx
    ) +
    scale_y_continuous(labels = scales::percent_format(accuracy = 0.01)) +
    theme_bw() +
    theme(
      plot.title = element_text(size = 12, face = "bold", hjust = 0.5, family = "sans"),
      plot.background = element_rect(fill = NA, colour = NA),
      axis.title = element_text(vjust = 0.5, hjust = 0.5, family = "sans", size = 10),
      axis.text.y = element_text(colour = "black", size = 9, family = "sans"),
      axis.text.x = element_text(size = 9, angle = 60, hjust = 1),
      axis.ticks = element_line(colour = "black"),
      axis.line = element_line(colour = "black", linewidth = 0.4),
      panel.border = element_rect(fill = NA, color = NA, linetype = 1),
      panel.grid = element_blank(),
      legend.text = element_text(size = 10, family = "sans"),
      legend.background = element_rect(fill = "transparent", colour = NA),
      legend.margin = margin(t = 0, r = 1, b = 0, l = 0, unit = "pt"),
      plot.margin = unit(c(0.5, 0.5, 0.5, 0.5), "cm")
    )
  
  return(p)
}

pro=plot_proportion(RNAumap,vectorx = "kmeans", vector2 = "Cancer_Category",title_text="Cancer Categories")
pro_t=plot_proportion(RNAumap,vectorx ="Cancer_Category", vector2 = "kmeans" ,title_text="Cancer Categories")
pro_t

source_t=plot_proportion(RNAumap,vectorx = "Datasource", vector2 = "kmeans",title_text="Data Source")
source=plot_proportion(RNAumap,vectorx = "kmeans", vector2 = "Datasource",title_text="Data Source")
pro=plot_proportion(RNAumap,vectorx = "kmeans", vector2 = "Cancer_Category",title_text="Cancer Categories")
pro
pro_t=plot_proportion(RNAumap,vectorx ="Cancer_Category", vector2 = "kmeans" ,title_text="Cancer Categories")
pro_t
origin=plot_proportion(RNAumap,vectorx = "kmeans", vector2 = "Origin",title_text="Origin")
origin
origin_t=plot_proportion(RNAumap,vectorx = "Origin", vector2 ="kmeans" ,title_text="Origin",colors=gradient_colors2) #
origin_t
Cancer_t=plot_proportion(RNAumap,vectorx = "cancer", vector2 ="kmeans" ,title_text="Cancer",colors=gradient_colors) #
Cancer_t
Cancerp=plot_proportion(RNAumap,vectorx = "kmeans", vector2 ="cancer" ,title_text="Cancer") #
Cancerp

combined_plot <- ggarrange(source,source_t,pro, pro_t, origin,origin_t,Cancerp,Cancer_t,ncol = 2, nrow = 4)
combined_plot
ggsave("/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/plot/1211/TPMUMAP_T_CancerCat_proport_1210all.pdf", 
       egg::set_panel_size(pro_t, width=unit(3, "in"), height=unit(4, "in")), 
       width = 8, height = 6, units = 'in')
ggsave("/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/plot/1211/RNAUMAPpro_raw_combined_kmeans_6_1212.pdf", 
       combined_plot, width = 12, height = 24)

#---- 添加label
labeldata=RNAumap[RNAumap$ncell %in% compare[compare$kmeans.x != compare$kmeans.y,]$ncell,]
prb <- 
ggplot(RNAumap, aes(x=X1,y = X2,fill=kmeans)) +
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
  ggrepel::geom_label_repel(aes(label=ncell),RNAumap,
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
