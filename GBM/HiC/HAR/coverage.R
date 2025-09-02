library(ggplot2)
library(dplyr)
library(reshape2)
library(tidyr)
library(egg)
library(glue)
library(gridExtra)
library(ggpubr)

name='HARs'
# ---- input1 loop anchor coverage
overlap=read.csv('/cluster/home/futing/Project/GBM/HiC/HAR/loop_coverage/loop_coverage_final.txt',sep='\t')
data=melt(overlap,id.vars = 'chr',variable.name='Sample',value.name='OverlapRatio')

# ---- input2 HARs & HAQERs coverage
HAQERsc=read.csv('/cluster/home/futing/Project/GBM/HiC/HAR/HAQER_coverage/HAQER_coveragev2.txt',sep='\t',header=F)
HARsc = read.csv('/cluster/home/futing/Project/GBM/HiC/HAR/HAR_coverage/HAR_coveragev2.txt',sep='\t',header=F)
data=HAQERsc[,c(1,7)]
colnames(data)=c('chr','OverlapRatio')

# ---- input3 chip coverage
chip=read.csv('/cluster/home/futing/Project/GBM/HiC/HAR/ChIP_coverage/H3K27ac_coverage.txt',sep='\t')
data=melt(chip,id.vars = 'chr',variable.name='Sample',value.name='OverlapRatio')

# ---- input4 HARs loop anchor coverage in 4 sample
HARs=read.csv(glue('/cluster/home/futing/Project/GBM/HiC/HAR/{name}_coverage/{name}_sample_coverage.txt'),sep='\t')
HARs=read.csv('/cluster/home/futing/Project/GBM/HiC/HAR/HAR_coverage/HARs_sample_coverage.txt',sep='\t')
HARs_ratio=data.frame(chr=HARs$chr,GBM=HARs$lGBM/HARs$lHARs,
                      NHA=HARs$lNHA/HARs$lHARs,iPSC=HARs$liPSC/HARs$lHARs,
                      NPC=HARs$lNPC/HARs$lHARs)
HAQERs =read.csv('/cluster/home/futing/Project/GBM/HiC/HAR/HAQER_coverage/HAQER_sample_coverage.txt',sep='\t')
HAQERs_ratio = HAQERs %>% 
  mutate(
    GBM=lGBM/lHARs,NHA=lNHA/lHARs,iPSC=liPSC/lHARs,NPC=lNPC/lHARs
  ) %>% select(chr,GBM,NHA,iPSC,NPC)
  
data=melt(HARs_ratio,id.vars = 'chr',variable.name='Sample',value.name='OverlapRatio')

# ----- input4 corrected HARs sample coverage, using GBM/sample loop anchor length
length=read.csv('/cluster/home/futing/Project/GBM/HiC/HAR/loop_coverage/loop_length_final.txt',sep='\t')
rownames(length) = length$chr
length_ratio = length %>% 
  mutate(
    rGBM = GBM/GBM,
    rNHA = GBM/NHA,
    riPSC = GBM/iPSC,
    rNPC = GBM/NPC
  ) %>% select(rGBM,rNHA,riPSC,rNPC)
length_ratio=length_ratio[-24,]
rownames(HARs_ratio) = HARs_ratio$chr
HARs_ratio=HARs_ratio[,-1]
# 用每个样本的loop长度与GBM loop anchor的比值进行矫正
HARs_sratio= HARs_ratio*length_ratio
HARs_sratio$chr=rownames(HARs_sratio)
data=melt(HARs_sratio,id.vars = 'chr',variable.name='Sample',value.name='OverlapRatio')

# ----- input 4 corrected HARs sample coverage, using GBM/sample loop anchor length and HARs/HAQERs length
# calculate HARs/HAQERs ratio 
# 计算HARs与loop anchor的覆盖率时考虑上HARs HAQERs

HARsc = HARsc[,c(1,5)]
HAQERsc = HAQERsc[,c(1,5)]
colnames(HARsc)=c('chr','HARs')
colnames(HAQERsc)=c('chr','HAQERs')
Hratio=merge(HARsc,HAQERsc,by='chr') %>%
  mutate(
    ratio=HARs/HAQERs
  ) %>% select(chr,ratio,HARs,HAQERs)

# 矫正HAQERs, 乘上 HARs/HAQERs
HAQERs_cratio= merge(Hratio[,c(1,2)],HAQERs_ratio,by='chr')
HAQERs_cratio = HAQERs_cratio %>% 
  mutate(
    GBM=GBM*ratio,
    NHA=NHA*ratio,
    iPSC=iPSC*ratio,
    NPC=NPC*ratio
  ) %>% select(chr,GBM,NHA,iPSC,NPC)
rownames(HAQERs_cratio)=HAQERs_cratio$chr
HAQERs_cratio=HAQERs_cratio[,-1]

HAQERs_scratio = HAQERs_cratio*length_ratio
rm(HAQERs_cratio,HARs_cratio)
HAQERs_scratio$chr = rownames(HAQERs_scratio)
data=melt(HAQERs_scratio,id.vars = 'chr',variable.name='Sample',value.name='OverlapRatio')

# ---- input 5 HARs chip overlap
HARs_chip=read.csv('/cluster/home/futing/Project/GBM/HiC/HAR/HARs_coverage/H3K27ac/HARs_H3K27ac_coverage.txt',sep='\t')
HARs_chipratio = HARs_chip %>% 
  mutate(
    GBM=lGBM/lHARs,NPC=lNPC/lHARs
  ) %>% select(chr,GBM,NPC)
# rownames(HARs_cratio) = HARs_cratio$chr
# HARs_cratio=HARs_cratio[,-1]

ChipRatio = chip %>% 
  mutate(
    rGBM=GBM/GBM,
    rNPC=GBM/NPC
  ) %>% select(chr,rGBM,rNPC)
# rownames(ChipRatio)=ChipRatio$chr
# ChipRatio=ChipRatio[,-1]

HARs_rchip= merge(HARs_chipratio,ChipRatio,by='chr') %>% 
  mutate(
    NPC=NPC*rNPC
  ) %>% select(chr,GBM,NPC)

data=melt(HARs_chipratio,id.vars = 'chr',variable.name='Sample',value.name='OverlapRatio')
data=melt(HARs_rchip,id.vars = 'chr',variable.name='Sample',value.name='OverlapRatio')

# ---- plot
data$chr = factor(data$chr,levels=c(paste0('chr',seq(1,22)),'chrX','chrY'))
data <- data %>% filter(chr!='chrY')
p<-
  ggplot(data,aes(x = chr, y=OverlapRatio,group=Sample,color=Sample)) + #, group=Sample,color=Sample ,color='darkgreen'
  geom_line(linewidth=0.8)+
  geom_point(size=2)+
  scale_color_brewer(palette = 'Set1')+
  # scale_x_continuous(breaks=c(1:6),labels=levels(celltime_sum$time))+
  scale_y_continuous(labels = scales::percent_format(accuracy = 0.1)) +
  labs(
    #title="HAQERs Coverage",
    # title="OverlapRatio of HAQERs\nin loop anchors (Corrected)",
    # title='H3K27ac ChIP signal coverage',
    title="OverlapRatio of HARs in H3K27ac peaks",
    # title = "Loop Anchor Coverage",
       x = "Chromosome",
       y = "Overlap Ratio") +
  theme_bw()+####去掉灰色背景
  theme(plot.title = element_text(hjust=0.5,size=12, face=2),
        #plot.background = element_rect(fill = 'blue', colour = NA),####去掉绘图背景
        ####坐标轴样式及坐标轴标题样式###
        axis.title = element_text(face="bold",size=12),
        axis.text.x =  element_text(colour="black", size=10,angle=60,hjust = 1),
        axis.text.y = element_text(colour="black", size=10),
        axis.ticks = element_line(colour="black",linewidth = 0.5),
        axis.line = element_blank(),
        ####绘图背景线及边框####
        #panel.border = element_rect(fill=NA,color="black",linewidth = 1,linetype = 1),
        panel.grid = element_blank())
p
# loop overlap & HARs overlap
ggsave("/cluster/home/futing/Project/GBM/HiC/HAR/plot/HARs_CH3K27acOverlap.pdf", egg::set_panel_size(p, width=unit(4, "in"), height=unit(3, "in")), 
       width = 8, height = 6, units = 'in')
ggsave("/cluster/home/futing/Project/GBM/HiC/HAR/LoopOverlap.pdf", egg::set_panel_size(p, width=unit(4, "in"), height=unit(3, "in")), 
       width = 8, height = 6, units = 'in')
ggsave("/cluster/home/futing/Project/GBM/HiC/HAR/HAQERsCoverage.pdf", egg::set_panel_size(p, width=unit(4, "in"), height=unit(3, "in")), 
       width = 8, height = 6, units = 'in')
# HARs and loop anchor overlap
ggsave("/cluster/home/futing/Project/GBM/HiC/HAR/HAQERsLoopOverlap.pdf", egg::set_panel_size(p, width=unit(4, "in"), height=unit(3, "in")), 
       width = 8, height = 6, units = 'in')


# HARs 数据
p1<-
  ggplot(data,aes(x = chr, y=OverlapRatio,group=Sample,color=Sample)) + #, group=Sample,color=Sample ,color='darkgreen'
  geom_line(linewidth=0.8)+
  geom_point(size=2)+
  scale_color_brewer(palette = 'Set1')+
  # scale_x_continuous(breaks=c(1:6),labels=levels(celltime_sum$time))+
  scale_y_continuous(labels = scales::percent_format(accuracy = 0.1)) +
  labs(
    title="OverlapRatio of HARs\nin loop anchors",
    x = "Chromosome",
    y = "Overlap Ratio") +
  theme_bw()+####去掉灰色背景
  theme(plot.title = element_text(hjust=0.5,size=12, face=2),
        #plot.background = element_rect(fill = 'blue', colour = NA),####去掉绘图背景
        ####坐标轴样式及坐标轴标题样式###
        axis.title = element_text(face="bold",size=12),
        axis.text.x =  element_text(colour="black", size=10,angle=60,hjust = 1),
        axis.text.y = element_text(colour="black", size=10),
        axis.ticks = element_line(colour="black",linewidth = 0.5),
        axis.line = element_blank(),
        ####绘图背景线及边框####
        #panel.border = element_rect(fill=NA,color="black",linewidth = 1,linetype = 1),
        panel.grid = element_blank(),
        legend.position = "none")
p1
# HAQER 数据
p2 <-
  ggplot(data,aes(x = chr, y=OverlapRatio,group=Sample,color=Sample)) + #, group=Sample,color=Sample ,color='darkgreen'
  geom_line(linewidth=0.8)+
  geom_point(size=2)+
  scale_color_brewer(palette = 'Set1')+
  scale_y_continuous(labels = scales::percent_format(accuracy = 0.1)) +
  labs(
    title="OverlapRatio of HAQERs\nin loop anchors (Corrected)",
    x = "Chromosome",
    y = "Overlap Ratio") +
  theme_bw()+####去掉灰色背景
  theme(plot.title = element_text(hjust=0.5,size=12, face=2),
        #plot.background = element_rect(fill = 'blue', colour = NA),####去掉绘图背景
        ####坐标轴样式及坐标轴标题样式###
        axis.title = element_text(face="bold",size=12),
        axis.text.x =  element_text(colour="black", size=10,angle=60,hjust = 1),
        axis.text.y = element_text(colour="black", size=10),
        axis.ticks = element_line(colour="black",linewidth = 0.5),
        axis.line = element_blank(),
        ####绘图背景线及边框####
        #panel.border = element_rect(fill=NA,color="black",linewidth = 1,linetype = 1),
        panel.grid = element_blank(),legend.position = "none")
p2
p3 <- get_legend(
  ggplot(data,aes(x = chr, y=OverlapRatio,group=Sample,color=Sample)) + #, group=Sample,color=Sample ,color='darkgreen'
    geom_line(linewidth=0.8)+
    geom_point(size=2)+
    scale_color_brewer(palette = 'Set1')+
    # scale_x_continuous(breaks=c(1:6),labels=levels(celltime_sum$time))+
    scale_y_continuous(labels = scales::percent_format(accuracy = 0.1)) +
    labs(
      title="OverlapRatio of HAQERs\nin loop anchors (Corrected)",
      x = "Chromosome",
      y = "Overlap Ratio") +
    theme_bw()+####去掉灰色背景
    theme(plot.title = element_text(hjust=0.5,size=12, face=2),
          #plot.background = element_rect(fill = 'blue', colour = NA),####去掉绘图背景
          ####坐标轴样式及坐标轴标题样式##RNARNA#
          axis.title = element_text(face="bold",size=12),
          axis.text.x =  element_text(colour="black", size=10,angle=60,hjust = 1),
          axis.text.y = element_text(colour="black", size=10),
          axis.ticks = element_line(colour="black",linewidth = 0.5),
          axis.line = element_blank(),
          ####绘图背景线及边框####
          #panel.border = element_rect(fill=NA,color="black",linewidth = 1,linetype = 1),
          panel.grid = element_blank())
)
lay = rbind(c(1,1,2,2,3))
combined_plot <- grid.arrange(p1, p2,p3, layout_matrix = lay,padding = unit(0.01, "cm"))
ggsave("/cluster/home/futing/Project/GBM/HiC/HAR/plot/HloopCoverage.pdf", combined_plot, width = 10, height = 4)



