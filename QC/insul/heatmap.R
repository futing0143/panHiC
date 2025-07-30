pacman::p_load(readxl,ggplot2,egg,janitor,reshape2,RColorBrewer,dplyr,stringr) #,harrypotter,ochRe,dutchmasters
setwd('/cluster2/home/futing/Project/panCancer/QC/insul')

# 01 read in data
insul=read.csv('/cluster2/home/futing/Project/panCancer/QC/insul/cancer_Jun26.bed',sep='\t',header=T,check.names = F)
colnames(insul) <- make.unique(colnames(insul),sep='_')

meta =read.csv('/cluster2/home/futing/Project/panCancer/QC/cancer_meta.txt',check.names = F,header=F)
colnames(meta)=c('cancer','gse','cell','enzyme')
meta$cell <- make.unique(meta$cell,sep='_')

df_clean <- insul %>%
  as_tibble() %>%  
  dplyr::select(-chrom, -start, -end) %>%
  filter(rowSums(is.na(.)) / ncol(.) <= 0.5)
#
corinsul = cor(df_clean,use="pairwise.complete.obs")
meta=meta[match(colnames(corinsul),meta$cell),]
annotation_col <- data.frame(factor(meta$cancer))
rownames(annotation_col) <- meta$cell
colnames(annotation_col) <- 'Cancer'
annocolors= list(
  Cancer= c(TALL="#16365F",MB="#77A3BB",CRC="#D64F38")
)
pheatmap::pheatmap(corinsul,         
                   annotation_col = annotation_col, 
                   annotation_colors = annocolors,
                   # color=c("#16365F","#77A3BB","#F8F2ED","#D64F38"),
                   color = colorRampPalette(c("#00688B", "#FFFFFF","red"))(100),
                   cluster_cols = T,
                   show_rownames = T,
                   show_colnames = F, 
                   scale = "row",         
                   ## none, row, column         
                   fontsize = 12,         
                   fontsize_row = 8,         
                   fontsize_col = 6,         
                   border = FALSE,         
                   treeheight_row = 0,
                   filename = 'heatmap.pdf')
