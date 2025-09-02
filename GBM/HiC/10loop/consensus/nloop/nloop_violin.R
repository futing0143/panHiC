library(readxl)
library(ggplot2)
library(ggpubr)
library(reshape2)
library(egg)
library(Hmisc)
library(dplyr)
library(harrypotter)
library(dutchmasters)
library(RColorBrewer)

# 计算 loop num, unique loop, overloop, overloop%

# 输入1 用全部的基因除
qc_loop = read.table('/Users/joanna/Documents/02.Project/GBM/04data/QC/inter2.txt',header=T,index=T)
pro_loop = qc_loop[,2:17] %>% apply(.,1,function(x){x/x[1]}) %>% t() %>% as.data.frame()
pro_loop =pro_loop[,-1]
rownames(pro_loop) =qc_loop$file_name

# 输入2 用并集除
pro_loop=read.table('/cluster/home/futing/Project/GBM/HiC/10loop/consensus/result/QC_1118/inter2p.txt',header=T)
exclude_list=c('ts543','ts667','GB176','GB180','GB182','GB183','GB238') #'astro1','astro2','ipsc','NPC','pHGG','iPSC_new','NPC_new',
pro_loop=pro_loop[!(pro_loop$file_name %in% exclude_list),]
pro_loop=pro_loop[-grep("^G", pro_loop$file_name), ]
rownames(pro_loop) =pro_loop$file_name
pro_loop=pro_loop[,-c(1,2)]
#pro_loop=pro_loop[,-c(3,7,10,13,14)]

# preprocess
ord=apply(pro_loop,2,mean)
ordername=names(ord[order(ord)])
s=melt(pro_loop)
s$variable=factor(s$variable,levels=ordername)
colors <- colorRampPalette(brewer.pal(9, 'Paired'))(15)
# -----=----- pro of 2 software
#p=
  ggplot(s, aes(variable, value, fill=variable))+ 
  geom_violin(trim = FALSE) +
  geom_boxplot(color="black",width=0.25,linewidth=0.2,position=position_dodge(0.9),outlier.colour = NA)+
  #scale_fill_brewer(palette = 'Paired')+
  ggtitle("Proportion of loops defined by 2 softwares")+
  scale_fill_manual(values=colors)+
  ylim()
  #scale_y_continuous(labels = c('1','2','3'))+
  #scale_y_continuous(labels = c(expression(10^4.5), expression(10^5), expression(10^5.5), expression(10^6), expression(10^6.5), expression(10^7)))+
  
  labs(x="",y="",color="")+
  theme_bw()+####去掉灰色背景
  theme(plot.title = element_text(hjust=0.5,size=14, face=2),
        plot.background = element_rect(fill = NA, colour = NA),####去掉绘图背景
        ####坐标轴样式及坐标轴标题样式###
        axis.title.y = element_text(face="bold",size=12),
        axis.text.x =  element_text(colour="black", size=11,angle=60,hjust=1),
        axis.text.y =  element_text(colour="black", size=11),
        axis.ticks = element_line(colour="black",linewidth = 0.5),
        axis.line = element_blank(),
        ####绘图背景线及边框####
        panel.border = element_rect(color='black',linewidth = 1),
        panel.grid = element_blank(),###去掉网格线
        ####图例标题及样式####
        legend.position="none")
p
ggsave("/cluster/home/futing/Project/GBM/HiC/10loop/consensus/result/proloops_homer.pdf", egg::set_panel_size(p, width=unit(9, "in"), height=unit(3, "in")), 
       width = 12, height = 6, units = 'in')

# ---------- loop counts --------
loop_counts=read.table('/Users/joanna/Documents/02.Project/GBM/04data/loop_num.txt',header=T)
rownames(loop_counts)=loop_counts[,1]
loop_counts=loop_counts[,-c(1,5)]
ord=apply(loop_counts,2,mean)
ordername=names(ord[order(ord)])
s=melt(loop_counts)
s$variable=factor(s$variable,levels=ordername)
p=ggplot(s, aes(variable, value, fill=variable))+ 
  geom_violin(trim = FALSE) +
  scale_y_log10()+
  #geom_boxplot(color="black",width=0.25,linewidth=0.2,position=position_dodge(0.9),outlier.colour = NA)+
  scale_fill_brewer(palette = 'Paired')+
  ggtitle("Num of loops called by 5 softwares (10k)")+
  #scale_fill_manual(values=colors)+
  labs(x="",y="",color="")+
  theme_bw()+####去掉灰色背景
  theme(plot.title = element_text(hjust=0.5,size=14, face=2),
        plot.background = element_rect(fill = NA, colour = NA),####去掉绘图背景
        ####坐标轴样式及坐标轴标题样式###
        axis.title.y = element_text(face="bold",size=12),
        axis.text.x =  element_text(colour="black", size=11,angle=60,hjust=1),
        axis.text.y =  element_text(colour="black", size=11),
        axis.ticks = element_line(colour="black",linewidth = 0.5),
        axis.line = element_blank(),
        ####绘图背景线及边框####
        panel.border = element_rect(color='black',linewidth = 1),
        panel.grid = element_blank(),###去掉网格线
        ####图例标题及样式####
        legend.position="none")
ggsave("Num of loop.pdf", egg::set_panel_size(p, width=unit(4, "in"), height=unit(3, "in")), 
       width = 8, height = 6, units = 'in')

# ------- unique loop
uniq_loop=read.table('/Users/joanna/Documents/02.Project/GBM/04data/QC/unique_loop.txt',header=T)
rownames(uniq_loop)=uniq_loop[,1]
uniq_loop=uniq_loop[,-c(1)]
uniq_loop['cooldots']=uniq_loop['cooldots']+uniq_loop['cooldots_no']
uniq_loop=uniq_loop[,-4]
ord=apply(uniq_loop,2,mean)
ordername=names(ord[order(ord)])
s=melt(uniq_loop)
s$variable=factor(s$variable,levels=ordername)
p=ggplot(s, aes(variable, value, fill=variable))+ 
  geom_violin(trim = FALSE) +
  scale_y_log10()+
  #geom_boxplot(color="black",width=0.25,linewidth=0.2,position=position_dodge(0.9),outlier.colour = NA)+
  scale_fill_brewer(palette = 'Paired')+
  ggtitle("Num of unique loops (10k)")+
  #scale_fill_manual(values=colors)+
  labs(x="",y="",color="")+
  theme_bw()+####去掉灰色背景
  theme(plot.title = element_text(hjust=0.5,size=14, face=2),
        plot.background = element_rect(fill = NA, colour = NA),####去掉绘图背景
        ####坐标轴样式及坐标轴标题样式###
        axis.title.y = element_text(face="bold",size=12),
        axis.text.x =  element_text(colour="black", size=11,angle=60,hjust=1),
        axis.text.y =  element_text(colour="black", size=11),
        axis.ticks = element_line(colour="black",linewidth = 0.5),
        axis.line = element_blank(),
        ####绘图背景线及边框####
        panel.border = element_rect(color='black',linewidth = 1),
        panel.grid = element_blank(),###去掉网格线
        ####图例标题及样式####
        legend.position="none")
ggsave("Num of uniq loop.pdf", egg::set_panel_size(p, width=unit(4, "in"), height=unit(3, "in")), 
       width = 8, height = 6, units = 'in')
