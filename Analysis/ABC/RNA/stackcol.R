pacman::p_load(FactoMineR,scales,ggplot2,magrittr,dplyr,RColorBrewer,knitr,reshape2,extrafont,ggpubr,gridExtra,tibble)

meta =read.csv('/cluster2/home/futing/Project/panCancer/Analysis/QC/PC/PC1016.txt',sep='\t',check.names = F,header=F)
data=read.csv('/cluster2/home/futing/Project/panCancer/Analysis/QC/PC/merged_col5.tsv',sep='\t',check.names = F)

# 统计每个细胞系包含多少大于0
mat=data[,-c(1,2,3)]
count_matrix <- apply(mat, 2, function(x) {
  c(
    "A" = sum(x > 0, na.rm = TRUE),
    "B" = sum(x < 0, na.rm = TRUE),
    "non" = sum(x == 0, na.rm = TRUE),
    "NA" = sum(is.na(x))
  )
}) %>% t(.) %>% as.data.frame %>% rownames_to_column(.,var='cell')

# 转换 percent
dat= melt(count_matrix, id.vars = "cell", 
          variable.name = "Category", value.name = "Count") %>%
  group_by(cell) %>%
  mutate(Total = sum(Count),
         Percent = Count / Total) %>%
  ungroup()
dat$Category = factor(dat$Category,levels=c('A','B','non','NA'))


ggplot(dat, aes(x = cell, y = Percent, fill = Category)) +
  geom_col(position = "stack") +
  scale_fill_manual(values=c("#D64F38","#16365F","#F8F2ED","#77A3BB"))+
  labs(title = "Compatment distribution",
       x = "",
       y = "Proportion",
       fill = "Category") +
  scale_y_continuous(labels = percent_format(accuracy = 0.01)) +  # 两位小数
  theme_bw()+
  theme(plot.title = element_text(size=12, face="bold",hjust=0.5,family="sans"),
        plot.background = element_rect(fill = NA, colour = NA),
        axis.title= element_text(vjust=0.5,hjust=0.5,family = "sans",size=10),
        axis.text.y = element_text(colour="black", size=9,family = "sans"),
        axis.text.x = element_text(size=6,angle = 60, hjust = 1),
        axis.ticks = element_line(colour="black"),
        axis.line = element_line(colour = "black",linewidth =0.4),
        panel.border = element_rect(fill=NA,color=NA,linetype = 1),
        panel.grid=element_blank(),#去掉背景线
        legend.title = element_blank(),
        legend.text =element_text(size=10,family = "sans"),
        legend.background = element_rect(fill = "transparent", colour = NA),
        # legend.position = "none",
        legend.margin = margin(t = 0, r = 1, b = 0, l = 0, unit = "pt"),
        ###图周围的边距
        plot.margin = unit(c(0.5,0.5,0.5,0.5),"cm"))

