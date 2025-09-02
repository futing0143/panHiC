options(stringsAsFactors = F)
library(tidyverse)
library(clusterProfiler)
library(msigdbr)  #r
library(GSVA) 
library(GSEABase)
library(pheatmap)
library(limma)
library(BiocParallel)
setwd('/cluster/home/futing/Project/GBM/HiC/13mutation/ICGC')
load('/cluster/home/futing/Project/GBM/HiC/13mutation/ICGC/GSVA.RData')
# -------- 01 准备migsig数据
#### 对 MigDB( Molecular Signatures Database)中的基因集做GSVA分析  ####
## 用手动下载基因集做GSVA分析
d <- 'C:/Users/Lenovo/Desktop/test/gmt' #存放gmt文件的路径
gmtfs <- list.files(d,pattern = 'symbols.gmt')  # 路径下所有结尾为symbols.gmt文件
gmtfs
kegg_list <- getGmt(file.path(d,gmtfs[1])) 
go_list <- getGmt(file.path(d,gmtfs[2])) 
##基因集数据在pathway.txt文件中，也可以直接赋值sel_gmt
sel_gmt=read.table("pathway.txt",header = T,na.strings = c(" "),sep = "\t")
head(sel_gmt)
dim(sel_gmt)
sets=as.list(sel_gmt)
sets=lapply(sets, function(x) x[!is.na(x)])
#sets[1]

## 02 msigdbr包提取下载 一般尝试KEGG和GO做GSVA分析
# Homo sapiens Mus musculus
##KEGG
KEGG_df_all <-  msigdbr(species = "Homo sapiens", 
                        category = "C2",
                        subcategory = "CP:KEGG") 
KEGG_df <- dplyr::select(KEGG_df_all,gs_name,gs_exact_source,gene_symbol)
kegg_list <- split(KEGG_df$gene_symbol, KEGG_df$gs_name) ##按照gs_name给gene_symbol分组

##GO
GO_df_all <- msigdbr(species = "Homo sapiens",
                     category = "C5")  
GO_df <- dplyr::select(GO_df_all, gs_name, gene_symbol, gs_exact_source, gs_subcat)
GO_df <- GO_df[GO_df$gs_subcat!="HPO",]
go_list <- split(GO_df$gene_symbol, GO_df$gs_name) ##按照gs_name给gene_symbol分组


m_t2g <- msigdbr(species = "Homo sapiens", category = "H") %>% 
  dplyr::select(gs_name, entrez_gene) # gsea的处理
# 模仿gsva的处理
Hallmark_df <- msigdbr(species = "Homo sapiens", category = "H") %>% 
  dplyr::select(gs_name, gene_symbol, gs_exact_source, gs_subcat) 
Hallmark_list <- split(Hallmark_df$gene_symbol, Hallmark_df$gs_name)

# -------- 02 GSVA  ####
#GSVA算法需要处理logCPM, logRPKM,logTPM数据或counts数据的矩阵####
#dat <- as.matrix(counts)
#dat <- as.matrix(log2(edgeR::cpm(counts))+1)
RNA=read.table('RNA/count.txt',sep='\t',header=T)
rownames(RNA)=RNA$gene_id
RNA=RNA[,-1]
dat <- as.matrix(log2(edgeR::cpm(RNA))+1)

dat=read.csv('loopedSM/ConFreq_sur.csv',sep='\t',header=T)
rownames(dat)=dat$icgc_donor_id
sur=dat[,c(2,3,4)]
dat=dat[,-c(1,2,3,4)]
colnames(dat)[1:2]=c("5s_rRNA","75K")

SMfil=read.csv('loopedSM/nocodSMcount.txt',sep='\t',header=T)
dat1 = merge(dat, SMfil, by.x = "row.names", by.y = "icgc_donor_id", all = TRUE)
dat2<- dat1
dat2[, 2:(ncol(dat2) - 1)] <- dat1[, 2:(ncol(dat2) - 1)] / dat1[, ncol(dat2)]
rownames(dat2)=dat2$Row.names

dat=dat2[,-c(1,ncol(dat2))]
dat=dat[rownames(dat) %in% colnames(RNA),]
dat <- as.matrix(log2(dat+1))
dat <- t(dat) # 行是基因 列是样本
geneset <- go_list

gsva_mat <- gsva(expr=dat, 
                 gset.idx.list=geneset, 
                 kcdf="Gaussian" ,#"Gaussian" for logCPM,logRPKM,logTPM, "Poisson" for counts
                 # kcdf="Poisson",
                 verbose=T, 
                 parallel.sz = parallel::detectCores())#调用所有核
gsva_matrix<- gsva(as.matrix(exprMatrix), 
                   sets,method='ssgsea',
                   kcdf='Gaussian',abs.ranking=TRUE)
# 将矩阵转换为数据框
colnames(dat)=dat2$Row.names
gsva_df <- as.data.frame(gsva_mat)
colnames(gsva_df)=dat2$Row.names
gsva_df$pathway <- gsub(".*?_\\d+([A-Z]*_)", "", rownames(gsva_mat)) 
# 先不处理了"GOMF_BETA_1_3_GALACTOSYLTRANSFERASE_ACTIVITY"                                        
# "GOMF_UDP_GALACTOSE_BETA_N_ACETYLGLUCOSAMINE_BETA_1_3_GALACTOSYLTRANSFERASE_ACTIVITY"

write.csv(gsva_df,"loopedSM/ConFreq_gsva_go_matrix.csv")

# -------- 03 绘图
gsva_mat=read.csv('./gsva_go_matrix.csv')
rownames(gsva_mat)=gsva_mat$X
gsva_mat=gsva_mat[,-1]
gsva_mat=gsva_mat[,-387]

# scale
SV=apply(gsva_mat,1,var) %>% sort(., decreasing = TRUE) #返回排序 
gsva_matrix1<- t(scale(t(gsva_mat)))
#head(gsva_matrix1)
normalization<-function(x){
  return((x-min(x))/(max(x)-min(x)))}
nor_gsva_matrix1 <- normalization(gsva_matrix1) 
dim(nor_gsva_matrix1)
score.gsva.metab=as.data.frame(t(nor_gsva_matrix1))
rownames(score.gsva.metab)=dat2$Row.names
head(score.gsva.metab)

pdata=score.gsva.metab[,names(SV)[1:500]]

#k是预设的分组数，为了方便观察而已，可以自行修改或删除
pheatmap(s,
         scale="column",
         show_colnames=F, 
         show_rownames=T, 
         cluster_cols=T, 
         cluster_rows=T,
         cex=1,
         main="GSVA scores of ConFreqRatio",
         treeheight_col= 0,
         treeheight_row = 0,
         fontsize_row = 5,
         color = colorRampPalette(c('darkblue', 'white', 'red'))(50),
         clustering_distance_cols="euclidean", 
         #clustering_method="complete", 
         border_color=FALSE) #,,cutree_row = 3
p
cluster = cutree(p$tree_col,k=3) #from left to right 1 3 2
table(cluster)

#pdf("GSVA_heatmap.pdf",width=10,height=10)
#p
#dev.off()

#按热图分组提取样本
d=as.data.frame(cluster)
table(d$cluster)
d$sample=row.names(d)
a=as.data.frame(d[d[, "cluster"] == 1,])
a=dat[rownames(a),]
b=as.data.frame(d[d[, "cluster"] == 2,])
b=dat[rownames(b),]
c=as.data.frame(d[d[, "cluster"] == 3,])
c=dat[rownames(c),]

# ------------ 03 limma
#### 进行limma差异处理 ####
##设定 实验组exp / 对照组ctr
gl
exp="primed"
ctr="naive"

design <- model.matrix(~0+factor(group_list))
colnames(design) <- levels(factor(group_list))
rownames(design) <- colnames(gsva_mat)
contrast.matrix <- makeContrasts(contrasts=paste0(exp,'-',ctr),  #"exp/ctrl"
                                 levels = design)

fit1 <- lmFit(gsva_mat,design)                 #拟合模型
fit2 <- contrasts.fit(fit1, contrast.matrix) #统计检验
efit <- eBayes(fit2)                         #修正

summary(decideTests(efit,lfc=1, p.value=0.05)) #统计查看差异结果
tempOutput <- topTable(efit, coef=paste0(exp,'-',ctr), n=Inf)
degs <- na.omit(tempOutput) 
write.csv(degs,"gsva_go_degs.results.csv")

# ------------ 04 visualization

#### 对GSVA的差异分析结果进行热图可视化 #### 
##设置筛选阈值
padj_cutoff=0.05
log2FC_cutoff=log2(2)

keep <- rownames(degs[degs$adj.P.Val < padj_cutoff & abs(degs$logFC)>log2FC_cutoff, ])
length(keep)
dat <- gsva_mat[keep[1:50],] #选取前50进行展示

pheatmap::pheatmap(dat, 
                   fontsize_row = 8,
                   height = 10,
                   width=18,
                   annotation_col = gl,
                   show_colnames = F,
                   show_rownames = T,
                   filename = paste0('GSVA_go_heatmap.pdf'))


# 火山图

degs$significance  <- as.factor(ifelse(degs$adj.P.Val < padj_cutoff & abs(degs$logFC) > log2FC_cutoff,
                                       ifelse(degs$logFC > log2FC_cutoff ,'UP','DOWN'),'NOT'))

this_title <- paste0(' Up :  ',nrow(degs[degs$significance =='UP',]) ,
                     '\n Down : ',nrow(degs[degs$significance =='DOWN',]),
                     '\n adj.P.Val <= ',padj_cutoff,
                     '\n FoldChange >= ',round(2^log2FC_cutoff,3))


g <- ggplot(data=degs, 
            aes(x=logFC, y=-log10(adj.P.Val),
                color=significance)) +
  #点和背景
  geom_point(alpha=0.4, size=1) +
  theme_classic()+ #无网格线
  #坐标轴
  xlab("log2 ( FoldChange )") + 
  ylab("-log10 ( adj.P.Val )") +
  #标题文本
  ggtitle( this_title ) +
  #分区颜色                   
  scale_colour_manual(values = c('blue','grey','red'))+ 
  #辅助线
  geom_vline(xintercept = c(-log2FC_cutoff,log2FC_cutoff),lty=4,col="grey",lwd=0.8) +
  geom_hline(yintercept = -log10(padj_cutoff),lty=4,col="grey",lwd=0.8) +
  #图例标题间距等设置
  theme(plot.title = element_text(hjust = 0.5), 
        plot.margin=unit(c(2,2,2,2),'lines'), #上右下左
        legend.title = element_blank(),
        legend.position="right")

ggsave(g,filename = 'GSVA_go_volcano_padj.pdf',width =8,height =7.5)

# ------ 发散条形图/柱形偏差图
# 用KEGG的GSVA差异分析结果，显示通路的上下调及pvalue信息
#### 发散条形图绘制 ####
library(tidyverse)  # ggplot2 stringer dplyr tidyr readr purrr  tibble forcats
library(ggthemes)
library(ggprism)
p_cutoff=0.001
degs <- gsva_kegg_degs  #载入gsva的差异分析结果
Diff <- rbind(subset(degs,logFC>0)[1:20,], subset(degs,logFC<0)[1:20,]) #选择上下调前20通路     
dat_plot <- data.frame(id  = row.names(Diff),
                       p   = Diff$P.Value,
                       lgfc= Diff$logFC)
dat_plot$group <- ifelse(dat_plot$lgfc>0 ,1,-1)    # 将上调设为组1，下调设为组-1
dat_plot$lg_p <- -log10(dat_plot$p)*dat_plot$group # 将上调-log10p设置为正，下调-log10p设置为负
dat_plot$id <- str_replace(dat_plot$id, "KEGG_","");dat_plot$id[1:10]
dat_plot$threshold <- factor(ifelse(abs(dat_plot$p) <= p_cutoff,
                                    ifelse(dat_plot$lgfc >0 ,'Up','Down'),'Not'),
                             levels=c('Up','Down','Not'))

dat_plot <- dat_plot %>% arrange(lg_p)
dat_plot$id <- factor(dat_plot$id,levels = dat_plot$id)

## 设置不同标签数量
low1 <- dat_plot %>% filter(lg_p < log10(p_cutoff)) %>% nrow()
low0 <- dat_plot %>% filter(lg_p < 0) %>% nrow()
high0 <- dat_plot %>% filter(lg_p < -log10(p_cutoff)) %>% nrow()
high1 <- nrow(dat_plot)

p <- ggplot(data = dat_plot,aes(x = id, y = lg_p, 
                                fill = threshold)) +
  geom_col()+
  coord_flip() + 
  scale_fill_manual(values = c('Up'= '#36638a','Not'='#cccccc','Down'='#7bcd7b')) +
  geom_hline(yintercept = c(-log10(p_cutoff),log10(p_cutoff)),color = 'white',size = 0.5,lty='dashed') +
  xlab('') + 
  ylab('-log10(P.Value) of GSVA score') + 
  guides(fill="none")+
  theme_prism(border = T) +
  theme(
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank()
  ) +
  geom_text(data = dat_plot[1:low1,],aes(x = id,y = 0.1,label = id),
            hjust = 0,color = 'black') + #黑色标签
  geom_text(data = dat_plot[(low1 +1):low0,],aes(x = id,y = 0.1,label = id),
            hjust = 0,color = 'grey') + # 灰色标签
  geom_text(data = dat_plot[(low0 + 1):high0,],aes(x = id,y = -0.1,label = id),
            hjust = 1,color = 'grey') + # 灰色标签
  geom_text(data = dat_plot[(high0 +1):high1,],aes(x = id,y = -0.1,label = id),
            hjust = 1,color = 'black') # 黑色标签

ggsave("GSVA_barplot_pvalue.pdf",p,width = 15,height  = 15)

# ------------------ 绘制弦图
# 引入包
library(circlize)
#导入数据:列名为通路，行名为分组，填充值为平均GSVA结果
#分组信息
xuan1<-t(gsva_mat[rownames(path),]) %>% data.frame
identical(rownames(xuan1),rownames(moxing))
xuan1$group<-moxing$group
str(xuan1)
# 按照分组计算不同通路的平均值
library(data.table)
asd<-data.table::dcast(xuan1,group~,fun=mean)
# 按照分组计算不同通路的平均值
result <- xuan1 %>%
  group_by(group) %>%
  summarize(across(1:20, mean)) %>% data.frame
result1<-result
rownames(result1)<-result1$group
str(result1)
result1<-result1[,-1] %>% as.matrix()
chordDiagram(result1)
chordDiagram(result1, grid.col = grid.col,annotationTrack = "grid",transparency = 0.8)
