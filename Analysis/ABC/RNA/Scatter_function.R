pacman::p_load(ggplot2,magrittr,umap,dplyr,RColorBrewer,reshape2,extrafont,ggpubr,gridExtra,tibble,optparse,patchwork)

option_list <- list(
  make_option(c("-i", "--input"), type="character", help="input file"),
  make_option(c("-o", "--output"), type="character", default='/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/results/1224/',help="output dir"),
  make_option(c("-n", "--name"), type="character",default="TPM_1223_combined5")
)

opt <- parse_args(OptionParser(option_list = option_list))
log_step <- function(step, msg) {
  time <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  message(sprintf("[%s] [%s] %s", time, step, msg))
}

output_name=opt$name
output_dir=opt$output

log_step("01", "Loading input expression matrix")
data=read.csv(opt$input,sep='\t',check.names = F)
cat("Input file:", opt$input, "\n")

log_step("02", "Loading RNA metadata and preprocessing")
RNA_meta=read.csv('/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/results/RNAmeta.txt',check.names = F,sep='\t')
RNA_meta <- RNA_meta %>%
  mutate(
    Origin = ifelse(is.na(Origin), "Normal", Origin),
    across(c(cancer, Cancer_Category, Origin, Datasource), as.factor)
  )


# ----- 01 input
# if (process){
#   rownames(data) = paste0('PC_',c(1:nrow(data)))
#   data <- data %>%
#     as_tibble() %>%  
#     dplyr::select(-chrom, -start, -end) %>%
#     # na.omit(axis=1)
#     filter(rowSums(is.na(.)) / ncol(.) <= 0.5)
# }
# 取高变基因
log_step("03", "Selecting top 20% highly variable genes")
stopifnot(ncol(data) < nrow(data))  # 样本数应大于基因数
vars <- apply(data, 1, var, na.rm = TRUE)
fil <- floor(0.2 * length(vars))
top_var_indices <- order(vars, decreasing = TRUE)[1:fil]

df_filtered <- data[top_var_indices, ] %>%
  t() %>%
  replace(is.na(.), 0)

# ---- 02 PCA
log_step("04", "Running PCA")
com1_RNA <- prcomp(df_filtered , center = T,scale = TRUE)

# 提取PC score并确定分组###
RNA_pca <- com1_RNA$x %>%
  as.data.frame() %>%
  rownames_to_column("ncell") %>%
  left_join(RNA_meta, by = c("ncell" = "header"))


write.table(RNA_pca,paste0(output_dir,'/',output_name,'_top20p.txt'),
            sep='\t',row.names =F,quote=F)

# --- 03 Kmeans
set.seed(123) 
pc_cols <- grep("^PC", colnames(RNA_pca))
kmeans_result <- kmeans(RNA_pca[, pc_cols[1:20]], centers = 3)
RNA_pca['kmeans']=kmeans_result$cluster
RNA_pca$kmeans <- factor(RNA_pca$kmeans,levels=c(1:3))
RNA_pca <- RNA_pca %>% rename(X1 = PC1, X2 = PC2)

# ---- 04 plot
log_step("05", "Plotting for PCA")
summ<-summary(com1_RNA)
xlab<-paste0("PC1 (",round(summ$importance[2,1]*100,2),"%)")
ylab<-paste0("PC2 (",sprintf("%0.2f", summ$importance[2,2]*100),"%)")
g <- guide_legend("cancer")
set1 <- RColorBrewer::brewer.pal(11, "Paired") 
gradient_colors <- colorRampPalette(set1)(37) #%>% rev()
set2 <- RColorBrewer::brewer.pal(9, "Paired") 
gradient_colors2 <- colorRampPalette(set2)(9)#%>% rev()
source('/Users/joanna/Documents/02.Project/GBM/05code/RNA/plot_function.R')

pcacancer <- plot_umap_fill(RNA_pca,"cancer","Cancers",xlab=xlab,ylab=ylab,colors = gradient_colors,legendexist=F)
pcasource <- plot_umap_fill(RNA_pca, "Datasource", "Data Source",xlab=xlab,ylab=ylab,legendexist = F)
pcaCancerCate <- plot_umap_fill(RNA_pca, "Cancer_Category", "Cancer Categories",xlab=xlab,ylab=ylab,legendexist=F)
pcaorigin <- plot_umap_fill(RNA_pca, "Origin", "Origin",xlab=xlab,ylab=ylab,legendexist=F,colors = gradient_colors2)
pcakmeans <- plot_umap_fill(RNA_pca, "kmeans","Clusters",xlab=xlab,ylab=ylab,legendexist=F)
pcakmeans_legend <- plot_legend(RNA_pca,'kmeans',"Clusters")
pcacancer_legend <- plot_legend(RNA_pca,'cancer',"Cancers",gradient_colors)
pcasource_legend <- plot_legend(RNA_pca,"Datasource","Data Source")
pcaorgin_legend <- plot_legend(RNA_pca,"Origin","Origin",gradient_colors2)
pcacancertypes_legend <- plot_legend(RNA_pca,'Cancer_Category','Cancer Categories',gradient_colors2)

# ------ 组合2
legend_col1 <- arrangeGrob(pcacancer_legend,ncol = 1)

legend_col2 <- arrangeGrob(
  pcasource_legend,
  pcakmeans_legend,
  pcacancertypes_legend,
  pcaorgin_legend,
  ncol = 1
)

right_block <- arrangeGrob(
  legend_col1,
  legend_col2,
  ncol = 2,
  widths = c(1, 1)
)

# --- Left block (2×2 main plots) ---
left_block <- arrangeGrob(
  pcacancer, pcasource,
  pcakmeans, pcaCancerCate,
  pcaorigin,
  ncol = 2
)

# --- Layout matrix ---
lay <- rbind(
  c(1, 1, 2),
  c(1, 1, 2),
  c(1, 1, 2)
)

# --- Final arrange ---
combined_PCA_plot<- grid.arrange(
  left_block,
  right_block,
  layout_matrix = lay,
  padding = unit(0.01, "cm")
)

ggsave(paste0(output_dir,"/PCA_",output_name,"_combined5_top20p.pdf"), combined_PCA_plot, width = 12, height = 10)

# ================== UMAP
log_step("06", "Running UMAP")
pcdata=com1_RNA$x %>% as.data.frame(.) 
iris.umap = umap::umap(pcdata[1:15],
                       n_neighbors = 20,  # 设置邻居数
                       min_dist = 0.2,    # 设置最小距离
                       metric = "euclidean")
RNAumap <- data.frame(iris.umap$layout) %>%
  rownames_to_column('ncell') %>%
  left_join(RNA_meta, by = c('ncell' = 'header'))

kmeans_result <-kmeans(RNAumap[,c('X1','X2')],centers = 5,nstart=100,iter.max = 1000)
RNAumap['kmeans']=kmeans_result$cluster
RNAumap$kmeans = factor(RNAumap$kmeans,levels=c(1:5))

write.table(RNAumap,paste0(output_dir,"/UMAP_",output_name,"_top20p.txt"),sep="\t",row.names = F,quote = F)

#------ plot
log_step("07", "Plotting for UMAP")
set1 <- RColorBrewer::brewer.pal(11, "Paired") 
gradient_colors <- colorRampPalette(set1)(37) #%>% rev()
pusource <- plot_umap_fill(RNAumap, "Datasource", "Data Source",legendexist=F)
pukmeans <- plot_umap_fill(RNAumap, "kmeans", "Clusters",legendexist=F)
pucancer <- plot_umap_fill(RNAumap, "cancer", "Cancers",colors=gradient_colors,legendexist=F)
puCancerCate <- plot_umap_fill(RNAumap, "Cancer_Category", "Cancer Categories",legendexist=F)
puorigin <- plot_umap_fill(RNAumap, "Origin", "Origin",legendexist=F,colors=gradient_colors2)

pukmeans_legend <- plot_legend(RNAumap,'kmeans',"Clusters")
pucancer_legend <- plot_legend(RNAumap,'cancer',"Cancers",gradient_colors)
pusource_legend <- plot_legend(RNAumap,'Datasource','Data Source')
puCancerCate_legend <- plot_legend(RNAumap,'Cancer_Category','Cancer Categories')
puorigin_legend <- plot_legend(RNAumap,"Origin", "Origin",colors=gradient_colors2)


# ---- 5 plots
# --- Legend block ---
legend_col1 <- arrangeGrob(pucancer_legend, ncol = 1)
legend_col2 <- arrangeGrob(
  pusource_legend,
  pukmeans_legend,
  puCancerCate_legend,
  puorigin_legend,
  ncol = 1
)

right_block <- arrangeGrob(
  legend_col1,
  legend_col2,
  ncol = 2,
  widths = c(1, 1)
)
# --- Left block (2×2 main plots) ---
left_block <- arrangeGrob(
  pucancer, pusource,
  pukmeans, puCancerCate,puorigin,
  ncol = 2
)
# --- Layout matrix ---
lay <- rbind(
  c(1, 1, 2),
  c(1, 1, 2),
  c(1, 1, 2)
)

# --- Final arrange ---
combined_UMAP_plot<- grid.arrange(
  left_block,
  right_block,
  layout_matrix = lay,
  padding = unit(0.01, "cm")
)

ggsave(paste0(output_dir,"/UMAP_",output_name,"_combined5_top20p.pdf"), combined_UMAP_plot, width = 12, height = 10)


# --------------------- plot proportion
psource=plot_proportion(RNAumap,vectorx = "kmeans", vector2 = "Datasource",title_text="Data Source")
psource_t=plot_proportion(RNAumap,vectorx ="Datasource", vector2 = "kmeans" ,title_text="Data Source")
pro=plot_proportion(RNAumap,vectorx = "kmeans", vector2 = "Cancer_Category",title_text="Cancer Categories")
pro_t=plot_proportion(RNAumap,vectorx ="Cancer_Category", vector2 = "kmeans" ,title_text="Cancer Categories")
origin=plot_proportion(RNAumap,vectorx = "kmeans", vector2 = "Origin",title_text="Origin")
origin_t=plot_proportion(RNAumap,vectorx = "Origin", vector2 ="kmeans" ,title_text="Origin",colors=gradient_colors2) #
Cancer_t=plot_proportion(RNAumap,vectorx = "cancer", vector2 ="kmeans" ,title_text="Cancer",colors=gradient_colors) #
Cancerp=plot_proportion(RNAumap,vectorx = "kmeans", vector2 ="cancer" ,title_text="Cancer") #

combined_plot <- ggarrange(psource,psource_t,pro, pro_t, origin,origin_t,Cancerp,Cancer_t,ncol = 2, nrow = 4)
ggsave(paste0(output_dir,"/",output_name,".pdf"), 
       combined_plot, width = 12, height = 24)