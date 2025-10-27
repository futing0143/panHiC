
# --------- 数量统计
meta =read.csv('//cluster2/home/futing/Project/panCancer/Analysis/QC/ncancer/aligndone1016.txt',sep='\t',check.names = F,header=F)
colnames(meta)=c('cancer','gse','cell','ncell')
ncan=meta[,c(1,3)] %>% unique() %>% select(cancer) %>% table() %>% as.data.frame()
colnames(ncan) = c('cancer','Freq')
ncan[ncan$cancer=='GBM','Freq']=71
ncan_sorted <- ncan[order(-ncan$Freq), ]
ncan_sorted$cancer <- factor(ncan_sorted$cancer,levels=ncan_sorted$cancer)
# scale_fill_manual(values=c("#16365F","#77A3BB","#F8F2ED","#D64F38"))+##红蓝色
# scale_fill_manual(values = wes_palette("Royal1"))+###红金色
total_samples <- sum(ncan_sorted$Freq)
p<-
  ggplot(ncan_sorted, aes(x = cancer, y = Freq)) +
  geom_bar(stat = "identity", fill = "#16365F") +
  geom_text(aes(label = Freq), 
            vjust = -0.5,           # 垂直位置调整 (负值表示在柱子上方)
            color = "black", 
            size = 3) +
  theme_bw() +
  annotate("text", 
           x = Inf, y = Inf,
           # x = -Inf, y = Inf,
           label = paste("Total:", total_samples),
           hjust = 1.1, vjust = 2,
           color = "red", size = 4, fontface = "bold") +
  ylim(0, max(ncan_sorted$Freq) * 1.1)+
  labs(x='Cancer',y='num of samples')+
  # coord_flip()+
  theme(plot.background = element_rect(fill = NA, colour = NA),
        panel.border = element_rect(fill=NA,color=NA,linewidth = 1,linetype = 1),
        axis.line = element_line(colour="black",linewidth = 0.5),
        panel.grid = element_blank(),###去掉网格线,
        axis.text.x = element_text(angle = 90, hjust = 1))
p
ggsave("../ncancer/Cancer_337.pdf", egg::set_panel_size(p, width=unit(8, "in"), height=unit(3, "in")), 
       width = 12, height = 6, units = 'in')
