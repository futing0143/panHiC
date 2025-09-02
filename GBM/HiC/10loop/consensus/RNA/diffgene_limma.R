library(limma)
library(dplyr)
library(magrittr)
library(tibble)
exclude=metadata3[metadata3$subtype=="",'sample']
data <- data[,!colnames(data) %in% exclude]
data[is.na(data)]=0

##---- limma 的必需步骤
group <- c("Virgin","d6.5","d8.5","d11.5")
group_list= factor(rep(group,num),levels=group)

group=unique(metadata3$subtype[!metadata3$subtype==""])
group_list=factor(metadata3$subtype[!metadata3$subtype==""],levels=group)

colData=data.frame(row.names = colnames(data),group=group_list)
design <- model.matrix(~0+group,data=colData)  #把group设置成一个model matrix
colnames(design) <- gsub("group", "", colnames(design))
df.fit <- lmFit(data, design)  ## 数据与list进行匹配


df.matrix <- makeContrasts(Neural - Proneural, levels = design) ###确定谁与谁比较
fit <- contrasts.fit(df.fit, df.matrix)
  
##--使用经验贝叶斯方法来改善基因差异表达的统计估计
efit <- eBayes(fit)
##--在贝叶斯基础上，加上logFC筛选
tfit <- treat(fit, lfc=1)
##--差异基因结果
e <- decideTests(tfit)
summary(decideTests(tfit))

####### 导出差异结果
tempOutput <- topTable(efit,n = Inf, adjust = "fdr")
output_fc <- topTreat(tfit, coef=1, n=Inf)

nrDEG = na.omit(tempOutput) ## 去掉数据中有NA的行或列
diffsig <- nrDEG 

####------------------ limma 批量比较 ------------------------##
library(limma)
library(edgeR)

BatchLimmaVoomAnalysis <- function(countMatrix, group_list,num, outputDir = "BatchLimmaResults") {
  # 确保输出目录存在
  if (!dir.exists(outputDir)) {
    dir.create(outputDir, recursive = TRUE)
  }
  # 设置您希望应用的阈值
  log2FC_threshold <- 1  # 例如，只保留log2FC大于1的结果
  p_value_threshold <- 0.05  # 例如，只保留p值小于0.05的结果
  
  # 准备分析的数据和设计矩阵
  colData=data.frame(row.names = colnames(countMatrix),group=group_list)
  design <- model.matrix(~ 0 + group, data = colData)
  colnames(design) <- gsub("group", "", colnames(design))
  # 使用edgeR的calcNormFactors方法进行TMM标准化
  dge <- DGEList(counts = countMatrix)
  dge <- calcNormFactors(dge)
  countsPerMillion <- cpm(dge, log = TRUE, prior.count = 5) # 使用prior.count平滑低计数
  
  # 使用voom转换数据，与设计矩阵结合
  v <- voom(counts = dge, design = design, plot = FALSE) # 如果想查看voom图，将plot设置为TRUE
  
  # 使用limma进行差异表达分析
  fit <- lmFit(v, design)
  fit <- eBayes(fit)
  
  # 定义并执行所有可能的两两比较
  
  for (i in 1 : length(group)) {
    for (j in 1 : length(group)) {
      if (i != j){
        contrastName <- paste(group[i], "vs", group[j], sep = "_")
        contrast <- makeContrasts(contrast = paste(group[i],'-', group[j]), levels = design)
        contrastFit <- contrasts.fit(fit, contrasts = contrast)
        contrastFit <- eBayes(contrastFit)
        topTableRes <- topTable(contrastFit, n = Inf) # 获取所有基因的结果
        
        # 筛选满足阈值条件的结果
        #filteredResults <- topTableRes[topTableRes$logFC > log2FC_threshold & topTableRes$P.Value < p_value_threshold, ]
        
        # 保存结果
        contrastName <- paste(group[i], "vs", group[j], sep = "_")
        resultFileName <- paste(contrastName, ".csv", sep = "")
        write.csv(topTableRes, file = file.path(outputDir, resultFileName))}
    }
  }
}
count_en <- count
count_en$gene_id <- gsub("\\..*", "", rownames(count_en))
count_en <- aggregate(x = count_en[,1:12],   #此时exprSet的第三列开始是表达矩阵内容
                      by = list(gene_id=count_en$gene_id),   #按照相同symbol分组，在组内计算
                      FUN = max)   %>% column_to_rownames(var = 'gene_id') #原文中是计算最大值（max），也可以计算平均值（mean）或者中位数（median）

BatchLimmaVoomAnalysis(count_en,group=group_list,num,outputDir = "BatchLimmaResults_ensembl")
