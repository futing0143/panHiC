setwd('/cluster2/home/futing/Project/panCancer/Analysis/dchic')

pacman::p_load(FactoMineR,scales,ggplot2,magrittr,dplyr,RColorBrewer,
               ggtext,knitr,reshape2,extrafont,ggpubr,gridExtra,tibble)

cell =read.csv('cell_list.txt',sep='\t',check.names = F,header=F)
colnames(cell)=c('cancer','gse','cell','isctrl')

dat <- cell %>%
  count(cancer, isctrl) %>%  # 计算每个cancer-kmeans组合的计数
  group_by(cancer) %>%
  mutate(
    Total = sum(n),
    Percent = n / Total 
  ) %>%
  ungroup()

dat$isctrl=as.character(factor(dat$isctrl,
                               levels = c(0, 1),
                               labels = c("cancer", "ctrl")))
# 小字
total_samples=sum(dat$n)
cancer_samples <- filter(dat, isctrl == 'cancer') %>%
  summarise(total = sum(n)) %>%
  pull(total)
ctrl_samples <- filter(dat, isctrl == 'ctrl') %>%
  summarise(total = sum(n)) %>%
  pull(total)

dat$cancer=factor(dat$cancer,levels=unique(dat$cancer[order(dat$Total,decreasing = T)]))

p<-
ggplot(dat, aes(x = cancer, y = n, fill = isctrl)) +
  geom_col(position = "stack") +
  scale_fill_manual(values=c("#D64F38","#16365F"))+
  labs(title = "Sample distribution",
       x = "",
       y = "",
       fill = "") +
  # scale_y_continuous(labels = percent_format(accuracy = 0.01)) +  # 两位小数
  geom_text(
    data = unique(dat[c("cancer","Total")]),
    aes(x = cancer, y = Total, label = Total),
    vjust = -0.3, color = "black", size = 3,inherit.aes = FALSE)+
  geom_textbox(
    x = 30, y = 60,
    label = paste0(
      "Total: ", total_samples, "<br>",
      "Cancer: ", cancer_samples, "<br>",
      "Control: ", ctrl_samples
    ),
    hjust = 1, vjust = 1,
    box.color = "black",           # 边框颜色
    fill = "white",              # 背景
    width = unit(0.20, "npc"),   # 宽度
    halign = 0,                  # 左对齐（关键）
    size = 3.5,
    family = "sans"
  )+
  theme_bw()+
  theme(plot.title = element_text(size=12, face="bold",hjust=0.5,family="sans"),
        plot.background = element_rect(fill = NA, colour = NA),
        axis.title= element_text(vjust=0.5,hjust=0.5,family = "sans",size=10),
        axis.text.y = element_text(colour="black", size=9,family = "sans"),
        axis.text.x = element_text(size=8,angle = 60, hjust = 1),
        axis.ticks = element_line(colour="black"),
        axis.line = element_line(colour = "black",linewidth =0.4),
        panel.border = element_rect(fill=NA,color=NA,linetype = 1),
        panel.grid=element_blank(),#去掉背景线
        legend.text =element_text(size=10,family = "sans"),
        legend.background = element_rect(fill = "transparent", colour = NA),
        legend.position = c(0.85, 0.5),          # 图内右中
        legend.justification = c(0, 0.5),
        # legend.margin = margin(t = 0, r = 1, b = 0, l = 0, unit = "pt"),
        ###图周围的边距
        plot.margin = unit(c(0.5,0.5,0.5,0.5),"cm"))
ggsave("cancer_ctrl.pdf", egg::set_panel_size(p, width=unit(8, "in"), height=unit(3, "in")), 
       width = 10, height = 6, units = 'in')
