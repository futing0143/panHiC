pacman::p_load(FactoMineR,ggplot2,magrittr,RColorBrewer,knitr,reshape2,extrafont,ggpubr,gridExtra,tibble)
# 原始的数据
TPM_UMAP=read.csv("/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/results/1211/TPMUMAP_1212_all.txt",sep='\t',check.names = F)
# sva 处理的数据
TPMsva_UMAP=read.csv('/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/results/1224/UMAP_TPM_svacorrected_1224_top20p.txt',
                     sep='\t',check.names = F)
input=TPMsva_UMAP
# 步骤1: 识别在多个datasource中出现的clcel（没有）
multi_source_cancer <- input %>%
  group_by(cancer) %>%
  summarise(n_datasources = n_distinct(Datasource)) %>%
  filter(n_datasources >= 2) %>%
  pull(cancer)

# 步骤2: 为绘图准备数据
plot_data <- input %>%
  dplyr::mutate(
    is_multi = cancer %in% multi_source_cancer,
    datasource_label = ifelse(is_multi, Datasource, "Single source")
  )

# --- 先看所有
ggplot(plot_data, aes(x = X1, y = X2)) +
  # 先画单一数据源的细胞(灰色背景)
  geom_point(data = filter(plot_data, !is_multi), 
             fill = "gray80", stroke = 0.35, size = 1, alpha = 0.8, shape = 21, color = "black") +
  # 再画多数据源的细胞(按Datasource着色)
  geom_point(data = filter(plot_data, is_multi), 
             aes(fill = Datasource), stroke = 0.35, size = 2, alpha = 0.9, shape = 21, color = "black") +
  facet_wrap(~Datasource) +
  theme_classic() +
  labs(title = "Multi-Datasource Cancer highlighted",
       subtitle = paste0("Cancers from multiple Datasources: ", 
                         length(multi_source_cancer), " cancers"),
       color = "Data Source") +
  theme(legend.position = "right")


# -------- 分面展示
# 只显示在多个数据集中的cancer
plot_data_multi <- plot_data %>%
  filter(cancer %in% multi_source_cancer)
set1 <- RColorBrewer::brewer.pal(11, "Paired") 
gradient_colors <- colorRampPalette(set1)(19)
facet_cancer <- ggplot(plot_data_multi, aes(x = X1, y = X2, fill = datasource_label)) +
  geom_point(stroke = 0.35, size = 2, alpha = 0.9, shape = 21, color = "black") +
  # scale_color_manual(values=gradient_colors)+
  scale_fill_brewer(palette = 'Set1')+
  facet_wrap(~cancer) +
  theme_classic() +
  labs(title = "Multi-datasource cancers by source",
       subtitle = paste0(length(unique(plot_data_multi$datasource_label)), 
                         " cancer types from multiple sources"),
       color = "Cancer Type") +
  theme(
    legend.position = "right",
    legend.title = element_blank(),
    strip.background = element_rect(fill = "white", color = "black"),
    strip.text = element_text(face = "bold")
  )

ggsave("/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/plot/TPMsva_facet_cancer.pdf",
       facet_cancer,
       height =8,width=10 )
