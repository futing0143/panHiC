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

#species <- data.frame()
#list <- list.files(pattern=".txt")
#for(i in list)
#  {
# path <- i
#species <- merge(species, read.table(file = path),all=T)
#}

E1 <- read.csv('/cluster/home/futing/Project/GBM/HiC/06compartment/cooltools/E1.tsv',sep = '\t')
E1 <- E1[,-1]
E1 <- E1[, !(colnames(E1) %in% c('G208R1','G208R2','G213R1','G213R2'))]

rank <- apply(E1,2,function(x){
  x <- as.numeric(na.omit(x))
  r <- mean(x)
  return (r)
})
rank <- as.data.frame(rank)
rank$label <- rownames(rank)
rank <- rank[order(rank$rank),]
s <- melt(E1)
colnames(s) <- c('sample','PC1')
s$sample <-as.character(s$sample)
#s$sample <- factor(s$sample,levels=c("Caenorhabditis","TAIR10" ,"Drosophisa" ,"Saccharomyces" ,"Macaca" , "Homo" , "Oryctolagus", "Danio" ,"Rattus"  , "Mus_musculus" ))

s <- na.omit(s)
#############
#my_comparisons <- list(c("Caenorhabditis","Mus_musculus"),c("Caenorhabditis","Rattus"))
#spe <- 
  ggplot(s, aes(sample, PC1, fill=sample))+ 
  geom_violin(trim = FALSE) +
  #stat_boxplot(geom = "errorbar",width=0.3,linewidth=0.5,color="black")+
  geom_boxplot(color="black",width=0.25,linewidth=0.2,position=position_dodge(0.9),outlier.colour = NA)+
  #stat_compare_means(method = "t.test", 
  #label = "p.signif",##星号设置
  #                   comparisons = my_comparisons)+
  
  #scale_x_discrete(labels=c('Caenorhabditis elegans \n (WBcel235)', 'TAIR \n (10.1)','Drosophila melanogaster \n (BDGP6.32)', 'Saccharomyces cerevisiae \n (R64-1-1)',
  #                          'Macaca mulatta \n (Mmul_10)','Homo sapiens \n (GRCh38.p13)', 'Oryctolagus cuniculus \n (OryCun2.0)','Danio rerio \n (GRCz11)' , 
  #                          'Rattus norvegicus \n (mRatBN7.2)','Mus_musculus \n (GRCm39)'))+
  #scale_x_continuous(limits=c(0:52),breaks=seq(from=2,to=38,by=4),labels=c('Caenorhabditis elegans \n (WBcel235)', 'Danio rerio \n (GRCz11)' , 'Drosophila melanogaster \n (BDGP6.32)', 'Homo sapiens \n (GRCh38.p13)', 'Macaca mulatta \n (Mmul_10)', 'Mus_musculus \n (GRCm39)', 'Oryctolagus cuniculus \n (OryCun2.0)', 'Rattus norvegicus \n (mRatBN7.2)', 'Saccharomyces cerevisiae \n (R64-1-1)', 'TAIR \n (10.1)'))+
  scale_fill_brewer(palette = 'Set3')+
  labs(x="",y="PC1",color="")+
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
        legend.position = "none")
#ggsave("species_pval.pdf", egg::set_panel_size(spe, width=unit(10, "in"), height=unit(4, "in")), 
#       width = 15, height = 8, units = 'in')

