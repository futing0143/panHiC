library(ggplot2)
sloop=read.csv('/cluster/home/futing/Project/GBM/HiC/10loop/consensus/result/QC_6/sloop_sample.txt',sep="\t")
exclude_list=c('ts543','ts667','GB176','GB180','GB182','GB183','GB238') #'astro1','astro2','ipsc','NPC','pHGG','iPSC_new','NPC_new',
subtype=read.csv('/cluster/home/futing/Project/GBM/HiC/09insulation/meta_all.txt',sep='\t')
sloop=sloop[!(sloop$sample %in% exclude_list),]

sloop$type= ifelse(sloop$size > 1000000,1,0)
sloop=merge(sloop,subtype,by='sample')

size=size[order(size$avg_size),]
size <- sloop %>%
  group_by(sample) %>%
  summarize(avg_size = mean(size))

LVS <- sloop %>%
  group_by(subtype, chr) %>%
  summarize(
    ShortRatio = sum(type == 0) / n(),  # 小于1MB的比例
    LongRatio = sum(type == 1) / n()    # 大于1MB的比例
  )

LVS$LVS=LVS$ShortRatio/LVS$LongRatio
#LVS=merge(LVS,compare,by='sample',all=T)
#levels(LVS$subtype) <- c(levels(LVS$subtype), 'Control')
#LVS$subtype[is.na(LVS$subtype)] <- 'Control'
#LVS$sample=factor(LVS$sample,levels = size$sample)


LVS1 <- LVS %>%
  filter(LVS != 0 & LVS != Inf)

max_points <- LVS1 %>%
  group_by(subtype) %>%
  top_n(1, LVS)
min_points <- LVS1 %>%
  group_by(subtype) %>%
  top_n(-1, LVS)

LVS1=LVS1[order(LVS1$subtype),]
LVS1$subtype=factor(LVS1$subtype,levels=c('Mesenchymal','Proneural','Neural','Classical','Control','Unknown'))
pSVL=ggplot(LVS1, aes(x = subtype, y = LVS, color =subtype)) +
  geom_point(size = 2) +
  geom_text(data = max_points, aes(label = chr), vjust = -1.25, size = 3) +
  geom_text(data = min_points, aes(label = chr), vjust = 1.25, size = 3) +
  labs(x = "subtype", y = "Short/Long range Ratio", color = "TCGA subtypes") +
  ylim(0,60)+
  #coord_cartesian(ylim=c(5,6))+
  #scale_y_continuous(labels = c(expression(10^5), expression(10^5.25), expression(10^5.5), expression(10^5.75),expression(10^6)))+
  #scale_fill_hp(discrete = TRUE, option = "Always")+
  #scale_fill_dutchmasters(palette = "pearl_earring")+
  #scale_fill_brewer(palette = 'Set1')+
  #scale_fill_manual(values=c("#77A3BB","#16365F","#D64F38"))+ #kmeans color
  scale_color_manual(values=c("#16365F","#77A3BB","#FFCC99","#D64F38","#abdda4","#fdae61"))+ #subtype color
  theme_bw()+ ####去掉灰色背景
  theme(plot.title = element_text(size=12, face="bold",hjust=0.5,family="sans"),
        plot.background = element_rect(fill = NA, colour = NA),
        axis.title= element_text(vjust=0.5,hjust=0.5,family = "sans",size=10),
        axis.text.x =  element_text(colour="black", size=9,angle=60,hjust=1,family = "sans"),
        axis.text.y =  element_text(colour="black", size=11,family = "sans"),
        axis.ticks = element_line(colour="black"),
        axis.line = element_line(colour = "black",linewidth =0.4),
        panel.border = element_rect(fill=NA,color=NA,linetype = 1),
        panel.grid=element_blank(),#去掉背景线
        legend.title = element_text(size=10,family = "sans"),
        legend.text =element_text(size=10,family = "sans"),
        legend.background = element_rect(fill = "transparent", colour = NA),
        legend.position = "right",
        legend.margin = margin(t = 0, r = 1, b = 0, l = 0, unit = "pt"),
        ###图周围的边距
        plot.margin = unit(c(0.5,0.5,0.5,0.5),"cm"))
ggsave("/cluster/home/futing/Project/GBM/HiC/10loop/consensus/result/SVL_subtype.pdf", egg::set_panel_size(pSVL, width=unit(4, "in"), height=unit(3, "in")), 
       width = 12, height = 6, units = 'in')
