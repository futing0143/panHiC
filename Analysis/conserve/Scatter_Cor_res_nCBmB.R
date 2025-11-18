pacman::p_load(readxl,ggplot2,reshape2,knitr,dplyr,tidyverse)
setwd('/cluster2/home/futing/Project/panCancer/Analysis/conserve')

CB_data<- read.csv('/cluster2/home/futing/Project/panCancer/Analysis/conserve/midata/412/CB_data_50k800k.tsv',check.names = F,sep='\t')
CB_data=CB_data %>% na.omit()


data <- CB_data
set1 <- RColorBrewer::brewer.pal(11, "Paired") 
gradient_colors <- colorRampPalette(set1)(33) #%>% rev()

corR=sprintf("%0.3f",cor(data$res, data$nCBmB_ratio, method = "pearson"))
p <- ggplot(data = data, aes(x=res,y=nCBmB_ratio))+
  geom_point(aes(fill=cancer),stroke=0.35,shape=21,size=2,color="black",alpha=0.8) +
  scale_fill_manual(values=gradient_colors)+
  geom_smooth(formula=y~x,color="red",method = lm,se=FALSE)+
  labs(x="nContacts",y="mCBmB_ratio",color="",fill="Cancers")+
  scale_x_continuous(labels = c(expression(italic(0)),
                                expression(1%*%10^10),
                                expression(2%*%10^10),
                                expression(3%*%10^10),
                                expression(4%*%10^10)),
                     #position = "right",
                     expand = c(0.05,0), #两侧0.05留白
                     breaks = c(0,1e8,2e8,3e8,4e8))+
    annotate('text',x=4e8,y=0.25,label=paste("R =",cor,sep = " "),size=4,fontface="bold")+
  
  theme_bw()+####去掉灰色背景
  theme(plot.title = element_text(hjust=0.5,size=14, face=2),
        plot.background = element_blank(),####去掉绘图背景
        ####坐标轴样式及坐标轴标题样式###
        axis.title.x = element_text(face="bold",size=12,margin=margin(t=3)),
        axis.title.y = element_text(face="bold",size=12,margin=margin(r=3)),
        axis.text =  element_text(colour="black", size=11),
        axis.ticks = element_line(colour="black",linewidth = 0.5),
        axis.line = element_line(colour="black",linewidth = 0.75),
        ####绘图背景线及边框####
        panel.border = element_blank(),
        ###去掉网格线
        panel.grid = element_blank(),
        ## legend
        legend.text = element_text(size=10),
        legend.title = element_text(size=12))


ggsave("./plot/412/Cor(nCMmB_ratio_nContacts).pdf", egg::set_panel_size(p, width=unit(4, "in"), height=unit(4, "in")), 
       width = 8, height = 7, units = 'in')
