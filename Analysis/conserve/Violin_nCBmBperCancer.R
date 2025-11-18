pacman::p_load(readxl,ggplot2,reshape2,knitr,dplyr,tidyverse,ggpubr,egg,rstatix)
setwd('/cluster2/home/futing/Project/panCancer/Analysis/conserve')

CB_data<- read.csv('/cluster2/home/futing/Project/panCancer/Analysis/conserve/midata/412/CB_data_50k800k.tsv',check.names = F,sep='\t')
CB_data=CB_data %>% na.omit()


sigdata <- CB_data %>%
  # pairwise_t_test(nCBmB_ratio ~ cancer, p.adjust.method = "BH") %>%
  pairwise_wilcox_test(nCBmB_ratio ~ cancer)%>%
  select(group1, group2, p)
data <- CB_data
set1 <- RColorBrewer::brewer.pal(11, "Paired") 
gradient_colors <- colorRampPalette(set1)(33) #%>% rev()


my_comparisons <- list(c("15","12"),c("15","6"),c("15","8"))
order_cancer <- data %>%
  group_by(cancer) %>%
  summarise(mean_ratio = mean(nCBmB_ratio, na.rm = TRUE)) %>%
  arrange(desc(mean_ratio)) %>%       # 按平均值升序
  pull(cancer)                  # 提取排序后的 cancer 名称

data$cancer <- factor(data$cancer,levels =  order_cancer)
data <- data %>%
  group_by(cancer) %>%
  filter(n() >= 2)
# spe <- 
# violin of the cancer
vio <- 
  ggplot(data, aes(cancer, nCBmB_ratio, fill=cancer))+ 
  # geom_violin(trim = FALSE) +
  #stat_boxplot(geom = "errorbar",width=0.3,linewidth=0.5,color="black")+
  geom_boxplot(color="black",width=0.25,linewidth=0.2,position=position_dodge(0.9),outlier.colour = NA)+
  # scale_x_discrete(labels=rank$State)+
  # stat_compare_means(method = "t.test", 
  #                    #label = "p.signif",##星号设置
  #                    comparisons = my_comparisons)+
  scale_fill_manual(values=gradient_colors)+
  labs(x="Cancer",y="Conserve Boundary Ratio",color="")+
  theme_bw()+####去掉灰色背景
  theme(plot.title = element_text(hjust=0.5,size=14, face=2),
        plot.background = element_blank(),####去掉绘图背景
        ####坐标轴样式及坐标轴标题样式###
        axis.title = element_text(face="bold",size=12),
        axis.text.x =  element_text(colour="black", size=11,angle=60,hjust=1),
        axis.text.y =  element_text(colour="black", size=11),
        axis.ticks = element_line(colour="black",linewidth = 0.5),
        axis.line = element_line(colour="black",linewidth = 0.5),
        ####绘图背景线及边框####
        panel.border = element_blank(),
        panel.grid = element_blank(),###去掉网格线
        ####图例标题及样式####
        legend.position = "none")
ggsave("./plot/412/Vio_nCMmB_ratio_per_cancer).pdf", egg::set_panel_size(vio, width=unit(5, "in"), height=unit(3, "in")), 
       width = 8, height = 7, units = 'in')


# ------------- 上面的图的hist
dat = table(data$cancer) %>% as.data.frame()
colnames(dat)=c('cancer','n')
dat$cancer = factor(dat$cancer,levels =  order_cancer)
dat <- dat %>%
  filter(n >= 2)
hist <- 
ggplot(dat, aes(x = cancer, y = n)) +
  geom_col(position = "stack",fill="#16365F") +
  scale_fill_manual(values=gradient_colors)+
  labs(title = "Sample distribution",
       x = "",
       y = "",
       fill = "") +
  # scale_y_continuous(labels = percent_format(accuracy = 0.01)) +  # 两位小数
  geom_text(
    data = unique(dat[c("cancer","n")]),
    aes(x = cancer, y = n, label = n),
    vjust = -0.3, color = "black", size = 3,inherit.aes = FALSE)+
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
        # legend.position = c(0.85, 0.5),          # 图内右中
        legend.justification = c(0, 0.5),
        # legend.margin = margin(t = 0, r = 1, b = 0, l = 0, unit = "pt"),
        ###图周围的边距
        plot.margin = unit(c(0.5,0.5,0.5,0.5),"cm"))

ggsave("./plot/412/Hist_nCMmB_ratio_per_cancer.pdf", egg::set_panel_size(hist, width=unit(5, "in"), height=unit(3, "in")), 
       width = 8, height = 7, units = 'in')


