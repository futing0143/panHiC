#/cluster/home/futing/Project/GBM/HiC/10loop/peakachu/peakachu.sh得到每个type的每条染色体的长度，再以1兆区分长互作短互作 整理成Excel，用R读入
library(ggplot2)
sloop=read.csv('/cluster/home/futing/Project/GBM/HiC/10loop/consensus/result/QC_6/sloop_sample.txt',sep="\t")
exclude_list=c('ts543','ts667','GB176','GB180','GB182','GB183','GB238') #'astro1','astro2','ipsc','NPC','pHGG','iPSC_new','NPC_new',
subtype=read.csv('/cluster/home/futing/Project/GBM/HiC/09insulation/meta_all.txt',sep='\t')
sloop=sloop[!(sloop$sample %in% exclude_list),]

sloop$type= ifelse(sloop$size > 1000000,1,0)
sloop=merge(sloop,subtype,by='sample')

sloop$type= ifelse(sloop$size > 1000000,1,0)
size <- sloop %>%
  group_by(sample) %>%
  summarize(avg_size = mean(size))

size_chr <- sloop %>%
  group_by(subtype,chr) %>%
  summarize(avg_size = mean(size)) # 没啥用


size=size[order(size$avg_size),]
size$sample=factor(size$sample,levels = size$sample)
size_chr$sample=factor(size_chr$sample,levels = size$sample)
sloop$sample=factor(sloop$sample,levels=size$sample)


my_colors<- rev(colorRampPalette(c("#A50026","#D73027","#F46D43","#FDAE61" ,"#FEE090","#FFFFBF","#E0F3F8","#ABD9E9","#74ADD1","#4575B4","#313695"))(61))

sloop$subtype=factor(sloop$subtype,levels=c('Mesenchymal','Proneural','Neural','Classical','Control','Unknown'))
p=
  ggplot(sloop, aes(subtype, log10(size), fill=subtype))+ 
    geom_violin(trim = FALSE) +
    #scale_y_continuous(labels = c(expression(10^5), expression(10^6), expression(10^7), expression(10^8)))+
    geom_boxplot(color="black",width=0.25,linewidth=0.2,position=position_dodge(0.9),outlier.colour = NA)+
  stat_compare_means(comparisons = list(
                                        c("Mesenchymal", "Proneural"),
                                        c("Mesenchymal", "Neural"),
                                        c("Mesenchymal", "Classical"),
                                        c("Mesenchymal", "Control")))+
    ggtitle("Loop sizes of different subtypes")+
    scale_fill_manual(values=c("#16365F","#77A3BB","#FFCC99","#D64F38","#abdda4","#fdae61"))+
    coord_cartesian(ylim=c(4,10))+
    scale_y_continuous(labels = c(expression(10^4), expression(10^6), expression(10^8), expression(10^10)))+
    #scale_fill_manual(values=my_colors)+
    labs(x="",y="",color="")+
    theme_bw()+####去掉灰色背景
    theme(plot.title = element_text(hjust=0.5,size=14, face=2),
          plot.background = element_rect(fill = NA, colour = NA),####去掉绘图背景
          ####坐标轴样式及坐标轴标题样式###
          axis.title.y = element_text(face="bold",size=12),
          axis.text.x =  element_text(colour="black", size=9,angle=60,hjust=1),
          axis.text.y =  element_text(colour="black", size=10),
          axis.ticks = element_line(colour="black",linewidth = 0.5),
          axis.line = element_line(colour="black",linewidth = 0.5),
          ####绘图背景线及边框####
          panel.border = element_rect(color=NA,linewidth = 1),
          panel.grid = element_blank(),###去掉网格线
          ####图例标题及样式####
          legend.position="none")
ggsave("/cluster/home/futing/Project/GBM/HiC/10loop/consensus/result/loopsize_subtype_violin.pdf", egg::set_panel_size(p, width=unit(5, "in"), height=unit(4, "in")), 
       width = 12, height = 6, units = 'in')
  


  
  #
summary <- summary %>%
  mutate(ShortRatio = ShortCount / TotalCount,
         LongRatio = LongCount / TotalCount)
summary$shortVSlong = summary$ShortRatio / summary$LongRatio

max_points <- summary %>%
  group_by(type) %>%
  top_n(1, shortVSlong)
min_points <- summary %>%
  group_by(type) %>%
  top_n(-1, shortVSlong)

ggplot(summary, aes(x = type, y = shortVSlong, color = chrm)) +
  geom_point(size = 2) +
  geom_text(data = max_points, aes(label = chrm), vjust = -1.5, size = 3) +
  geom_text(data = min_points, aes(label = chrm), vjust = 1.5, size = 3) +
  labs(x = "Cell Type", y = "Short/Long range Ratio", color = "Chromosome") +
  scale_color_discrete(name = "Chromosome") +
  theme_minimal()
