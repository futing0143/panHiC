# /cluster/home/tmp/GBM/RNA/subtype_TPM/count_merge/allcount_G.txt  count表达矩阵
# /cluster/home/tmp/GBM/RNA/subtype_TPM/ssGSEA/colodata_allTPM.txt 分组信息
library("Deseq2")
counts_matrix <- merged_data_G[,-1]
counts_matrix=round(counts_matrix)
# 读取分组信息
sample_info <- read.table("colodata_all.txt",header = T)

# 确保样本名一致
all(colnames(counts_matrix) %in% sample_info$Sample)  # 应返回 TRUE
all(rownames(counts_matrix) != "")  # 确保基因名非空

# 定义一个函数来进行差异表达分析并分类
perform_differential_expression <- function(counts_matrix, sample_info, condition1, condition2) {
  # 筛选对应的样本
  selected_samples <- sample_info[sample_info$subtype %in% c(condition1, condition2), ]
  selected_samples$subtype <- factor(selected_samples$subtype, levels = c(condition2, condition1))  # 设置对照组为condition2
  
  # 筛选 counts_matrix 中对应的样本列
  counts_matrix_filtered <- counts_matrix[, colnames(counts_matrix) %in% selected_samples$Sample]
  counts_matrix_filtered <- counts_matrix_filtered[, match(selected_samples$Sample, colnames(counts_matrix_filtered))]
  
  # 构建 DESeq2 数据集对象
  dds <- DESeqDataSetFromMatrix(
    countData = counts_matrix_filtered,
    colData = selected_samples,
    design = ~ subtype
  )
  
  # 差异表达分析
  dds <- DESeq(dds)
  
  # 提取结果并分类
  res <- results(dds)
  res$category <- ifelse(
    res$padj < 0.05 & res$log2FoldChange > 0, "Upregulated in GBM",
    ifelse(res$padj < 0.05 & res$log2FoldChange < 0, "Downregulated in GBM", "No significant change")
  )
  
  # 返回结果
  return(res)
}

# 创建空的数据框，最终将存储所有比较的结果
final_result <- data.frame(Gene = rownames(counts_matrix))

# 分别进行 GBM vs NPC, GBM vs iPSC, GBM vs NHA 的差异表达分析
res_GBM_NPC <- perform_differential_expression(counts_matrix, sample_info, "GBM", "NPC")
res_GBM_iPSC <- perform_differential_expression(counts_matrix, sample_info, "GBM", "iPSC")
res_GBM_NHA <- perform_differential_expression(counts_matrix, sample_info, "GBM", "NHA")

# 添加每个比较的结果到最终表格
final_result$GBM_vs_NPC <- res_GBM_NPC$category
final_result$GBM_vs_iPSC <- res_GBM_iPSC$category
final_result$GBM_vs_NHA <- res_GBM_NHA$category
# 删除第2列到第4列都是 NA 的行
final_result_cleaned <- final_result[apply(final_result[, 2:4], 1, function(x) !all(is.na(x))), ]

# 保存结果到 CSV 文件
write.table(final_result_cleaned, file = "Gene_Expression_Categories_GBM_vs_NPC_iPSC_NHA.txt", sep = '\t',row.names = FALSE,quote = F)

