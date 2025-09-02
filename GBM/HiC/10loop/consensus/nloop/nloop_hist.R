library(readxl)
library(ggplot2)
library(reshape2)
library(egg)
library(ochRe)
library(harrypotter)
library(dutchmasters)
library(RColorBrewer)

# ------ 计算高置信度的loop数目
count<- read.table('/Users/joanna/Documents/02.Project/GBM/04data/QC/num_loop_over2.txt', header = F)
colnames(count) <- c('file','loop_num')
cluster_labels <- c(
  'Xu et al', 
  rep('Harewood et al', 5),
  rep('Johnson et al', 3),
  rep('Xie et al', 28),
  'Cheng et al',
  rep('Mathur et al', 21),
  'Xu et al',
  rep('Our', 2),
  'Xu et al',
  'Chen et al',
  rep('Xu et al', 2),
  'Cheng et al',
  rep('Control',2)
)
count$dataset <- cluster_labels
write.table(count,'/Users/joanna/Documents/02.Project/GBM/04data/Numofloops_10k.txt',sep = '\t',row.names = F)

#count <- read.table('/Users/joanna/Documents/02.Project/GBM/04data/Numofloops_10k.txt',header=T)
count <- count[order(count$loop_num),]
count$file <- factor(count$file,levels = count$file)
count$dataset <- factor(count$dataset,levels=c('Control','Chen et al','Cheng et al','Harewood et al','Johnson et al','Mathur et al','Our','Xie et al','Xu et al'))
count <- count[!count$dataset == 'Harewood et al',]

p<-
  ggplot(data = count, aes(x=file,y=log10(loop_num),fill=dataset))+
  #geom_col(width=0.75)+
  labs(x="",y="",fill="Datasets",title = "Num of High-Confidence Loops at 10k")+
  #scale_y_log10(labels = scales::label_scientific())+
  #ggtitle("Num of High-Confidence Loops at 10k")+
  
  geom_bar(position=position_dodge(width=0.3), stat="identity",width = 0.6) +
  coord_cartesian(ylim=c(0,5))+
  scale_y_continuous(labels = c(expression(10^0), expression(10^1), expression(10^2), expression(10^3),expression(10^4),expression(10^5)))+
  #scale_fill_hp(discrete = TRUE, option = "Harry Potter")+
  #scale_fill_brewer(palette = "Paired")+
  #scale_fill_dutchmasters(palette = "pearl_earring")+
  #scale_fill_manual(values=c("#98C170", "#D7736B", "#FB9A99", "#7BBBAC","#9A6F9C","#A9A7BE", "#759BAF"))+
  scale_fill_manual(values=c("#FDBF6F","#E31A1C","#A9A7BE","#B2DF8A","#1F78B4", "#A6CEE3", "#D64F38" , "#33A02C"))+
  theme_bw()+####去掉灰色背景
  theme(plot.background = element_rect(fill = NA, colour = NA),####去掉绘图背景
        ####坐标轴样式及坐标轴标题样式###
        axis.title.x = element_text(family = "sans",face="bold",size=12,margin=margin(t=3)),
        #axis.title.y = element_text(family = "sans",face="bold",size=12,margin=margin(r=3)),
        axis.text.x =  element_text(colour="black", size=9,angle=60,hjust=1,family = "sans"),
        axis.text.y =  element_text(colour="black", size=11,family = "sans"),
        axis.ticks = element_line(colour="black",linewidth = 0.5),
        axis.line = element_blank(),
        ####绘图背景线及边框####
        panel.border = element_rect(fill=NA,color="black",linewidth = 1,linetype = 1),
        panel.grid = element_blank(),###去掉网格线
        ####图例标题及样式####
        legend.title = element_text(family = "sans",face="bold",size=12,margin=margin(r=3)),
        legend.text = element_text(size=11, family ="sans"),
        plot.title = element_text(hjust=0.5, family="sans", face="bold", size=14))# 将标题居中
#legend.background = element_rect(fill = "transparent", colour = NA),
#legend.position = "none",
#legend.margin = margin(t = 0, r = 1, b = 0, l = 0, unit = "pt"))+

###图周围的边距
#plot.margin = unit(c(1,1,2,1),"cm"))
ggsave("numofloop_fil.pdf", egg::set_panel_size(p, width=unit(8, "in"), height=unit(3, "in")), 
       width = 12, height = 6, units = 'in')

