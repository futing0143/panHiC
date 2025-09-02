library(ggplot2)
library(RColorBrewer)
library(ggpubr)
library(reshape2)
library(dplyr)
library(harrypotter)
library(dutchmasters)
library(viridis)

# 不同亚型的loop
my_colors <- rev(colorRampPalette(c('#d7191c','#fdae61','#ffffbf','#abdda4','#2b83ba'))(61))
my_colors<- rev(colorRampPalette(c("#A50026","#D73027","#F46D43","#FDAE61" ,"#FEE090","#FFFFBF","#E0F3F8","#ABD9E9","#74ADD1","#4575B4","#313695"))(61))
size=merge(size,compare,by='sample')
size$subtype=factor(size$subtype,levels=c('Mesenchymal','Classical','Proneural','Neural','Unknown'))
#p<-
ggplot(data = size, aes(x=sample,y=log10(avg_size),fill=kmeans.x))+
  #geom_col(width=0.75)+
  labs(x="",y="",fill="Kmeans",title = "Avg size of loops (bp)")+
  #scale_y_log10(labels = scales::label_scientific())+
  #ggtitle("Num of High-Confidence Loops at 10k")+
  
  geom_bar(position=position_dodge(width=0.3),color='black', stat="identity",width = 0.6,linewidth=0.1) +
  coord_cartesian(ylim=c(5,6))+
  scale_y_continuous(labels = c(expression(10^5), expression(10^5.25), expression(10^5.5), expression(10^5.75),expression(10^6)))+
  #scale_fill_hp(discrete = TRUE, option = "Always")+
  #scale_fill_dutchmasters(palette = "pearl_earring")+
  #scale_fill_brewer(palette = 'Set1')+
  scale_fill_manual(values=c("#77A3BB","#16365F","#D64F38"))+
  #scale_fill_manual(values=c("#16365F","#77A3BB","#FFCC99","#D64F38","#F8F2ED"))+
  theme_bw()+####去掉灰色背景
  theme(plot.background = element_rect(fill = NA, colour = NA),####去掉绘图背景
        ####坐标轴样式及坐标轴标题样式###
        axis.title.x = element_text(family = "sans",size=10),
        axis.text.x =  element_text(colour="black", size=9,angle=60,hjust=1,family = "sans"),
        axis.text.y =  element_text(colour="black", size=11,family = "sans"),
        axis.ticks = element_line(colour="black",linewidth = 0.5),
        axis.line = element_blank(),
        ####绘图背景线及边框####
        panel.border = element_rect(fill=NA,color="black",linewidth = 1,linetype = 1),
        panel.grid = element_blank(),###去掉网格线
        ####图例标题及样式####
        legend.position = "right",
        plot.title = element_text(hjust=0.5, family="sans", face="bold", size=12))
  