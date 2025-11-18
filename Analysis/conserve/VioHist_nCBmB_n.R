# data 来源后面的
dat <- data %>%
  group_by(cancer) %>%
  summarise(mean_ratio = mean(nCBmB_ratio, na.rm = TRUE),
            n = n()) %>%
  filter(n >= 2)

# 先算出比例之间的缩放系数（为了让两条轴在视觉上匹配）
ratio_max <- max(dat$mean_ratio)
count_max <- max(dat$n)
scale_factor <- ratio_max*0.6 / count_max

# 画图
p <- ggplot(dat, aes(x = cancer)) +
  # 左轴: violin/boxplot
  geom_boxplot(data = data, aes(y = nCBmB_ratio, fill = cancer),
               width = 0.5, color = "black", linewidth = 0.2, outlier.colour = NA) +
  # 右轴: 样本数量（需要按比例缩放）
  geom_col(aes(y = n * scale_factor),
           fill = "#16365F", width = 0.4, alpha = 0.4) +
  geom_text(aes(y = n * scale_factor, label = n),
            vjust = -0.5, size = 3, color = "black") +
  scale_fill_manual(values = gradient_colors) +
  scale_y_continuous(
    name = "Conserve Boundary Ratio",
    sec.axis = sec_axis(~./scale_factor, name = "Number of Samples")
  ) +
  labs(x = "Cancer") +
  theme_bw() +
  theme(
    plot.background = element_blank(),####去掉绘图背景
    axis.title.y.left = element_text( size = 12, color = "black"),
    axis.title.y.right = element_text( size = 12, color = "#16365F"),
    axis.text.x = element_text(angle = 60, hjust = 1, size = 10, color = "black"),
    axis.text.y = element_text(size = 10, color = "black"),
    axis.ticks = element_line(colour="black",linewidth = 0.5),
    # axis.line = element_line(colour="black",linewidth = 0.5),
    axis.line = element_blank(),
    panel.border = element_rect(color="black",linewidth = 0.6,fill=NA),
    # panel.grid = element_blank(),
    panel.grid.major = element_line(color = "gray80", linewidth = 0.2),  # 主要网格线
    panel.grid.minor = element_line(color = "gray90", linewidth = 0.1),   # 次要网格线
    legend.position = "none"
  )
p
ggsave("./plot/412/VioHist_n_nCBmB.pdf", egg::set_panel_size(p, width=unit(6, "in"), height=unit(3, "in")), 
       width = 8, height = 7, units = 'in')
