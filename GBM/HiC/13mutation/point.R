library(readxl)
library(ggplot2)
library(reshape2)
library(knitr)
library(magrittr)
library(dplyr)

SM=read.csv('/cluster/home/futing/Project/GBM/HiC/13mutation/2021.csv')
SM_short=SM[,c(1:6,3667:3670)]
colnames(SM_short)[7:10]=c('ConFreq','Orin','ConNum','ConFreqRatio')

death=SM_short[!is.na(SM_short$PATH_DIAG_TO_DEATH_DAYS),]
r=sprintf("%0.3f",cor(death$PATH_DIAG_TO_DEATH_DAYS,death$Orin, method = "pearson"))

p=ggplot(data = death, aes(x=PATH_DIAG_TO_DEATH_DAYS,y=Orin))+
  geom_point(size=1,color="#104E8B") +
  geom_smooth(formula=y~x,color="red",method = lm,se=F)+
  labs(x="Living days",y="Contact Frequency Ratio",color="")+
  annotate('text',x=700,y=750,label=paste("R =",r,sep = " "),size=4,fontface="bold")+
  theme_bw()+####去掉灰色背景
  theme(plot.title = element_text(hjust=0.5,size=14, face=2),
        plot.background = element_rect(fill = NA, colour = NA),####去掉绘图背景
        ####坐标轴样式及坐标轴标题样式###
        axis.title.x = element_text(size=12,margin=margin(t=3)),
        axis.title.y = element_text(size=12,margin=margin(r=3)),
        axis.text.x =  element_text(colour="black", size=11),
        axis.text.y =  element_text(colour="black", size=11),
        axis.ticks = element_line(colour="black",linewidth = 0.5),
        axis.line = element_line(colour="black",linewidth = 0.5),
        ####绘图背景线及边框####
        panel.border = element_rect(fill=NA,color=NA,linewidth = 1,linetype = 1),
        ###去掉网格线
        panel.grid = element_blank(),
        legend.position = "none")
p
ggsave("/cluster/home/futing/Project/GBM/HiC/13mutation/ConFreqall_Living.pdf", egg::set_panel_size(p, width=unit(3, "in"), height=unit(3, "in")), 
       width = 8, height = 6, units = 'in')

