pacman::p_load(readxl,ggplot2,egg,reshape2,RColorBrewer,harrypotter,dplyr,stringr) #,ochRe,dutchmasters
setwd('/cluster2/home/futing/Project/panCancer/Analysis/QC/nContacts')


# ------ 计算高置信度的loop数目
res<- read.table('/cluster2/home/futing/Project/panCancer/Analysis/QC/nContacts/res1015.txt',header=F,check.names=F)
colnames(res)= c('cancer','gse','cell','reso')
res <- res %>%
  group_by(cell) %>%  # 按 cell 分组
  mutate(
    suffix = if (n() > 1) paste0("_", row_number()) else "",  # 如果重复，添加 _1, _2...
    ncell = paste0(cell, suffix)  # 合并 cell 和 suffix
  ) %>%
  dplyr::select(-suffix) %>%
  filter(reso < 1000000)
res$ncell =factor(res$ncell,levels=res$ncell[order(res$reso)])


set1 <- RColorBrewer::brewer.pal(11, "Paired") 
gradient_colors <- colorRampPalette(set1)(33) #%>% rev()
plot(1:32, rep(1, 32), col = gradient_colors, pch = 19, cex = 5)

p<-
  ggplot(data = res, aes(x=ncell,y=log10(reso),fill=cancer))+
  geom_col(width=0.75)+
  labs(x="",y="",fill="Datasets",title = "Resolution calculated by Juicer")+
  # scale_y_log10(labels = scales::label_scientific())+ #1+e0这种写法
  # geom_bar(position=position_dodge(width=0.3), stat="identity",width = 0.6) +
  # coord_cartesian(ylim=c(5,8.2))+
  scale_y_continuous(labels = c(expression(10^0), expression(10^2), expression(10^4), expression(10^6)))+
  scale_fill_manual(values=gradient_colors)+ #[c(1,3,2,4:12)]
  theme_bw()+####去掉灰色背景
  theme(plot.background = element_blank(),####去掉绘图背景
        ####坐标轴样式及坐标轴标题样式###
        axis.title.x = element_text(family = "sans",face="bold",size=12,margin=margin(t=3)),
        #axis.title.y = element_text(family = "sans",face="bold",size=12,margin=margin(r=3)),
        axis.text.x =  element_blank(),
        axis.text.y =  element_text(colour="black", size=11,family = "sans"),
        axis.ticks.y = element_line(colour="black",linewidth = 0.5),
        axis.ticks.x = element_blank(),
        axis.line = element_line(colour="black",linewidth = 0.8),
        ####绘图背景线及边框####
        panel.border = element_blank(),
        # panel.border = element_rect(fill=NA,color="black",linewidth = 1,linetype = 1),
        panel.grid = element_blank(),###去掉网格线
        ####图例标题及样式####
        legend.title = element_text(family = "sans",face="bold",size=12,margin=margin(r=3)),
        legend.text = element_text(size=11, family ="sans"),
        plot.title = element_text(hjust=0.5, family="sans", face="bold", size=13))# 将标题居中

p
###图周围的边距
#plot.margin = unit(c(1,1,2,1),"cm"))
ggsave("reso_1031.pdf", egg::set_panel_size(p, width=unit(12, "in"), height=unit(3, "in")),
       width = 15, height = 6, units = 'in')
# p<-



