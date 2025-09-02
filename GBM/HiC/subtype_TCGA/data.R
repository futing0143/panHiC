# 加载必要的包
# library(dplyr)

#01 合并TPM矩阵 
# cancer_list <- readLines("/cluster/home/tmp/GBM/HiC/subtype_TCGA/list")

# # 定义文件路径的前缀
# file_path_prefix <- "/cluster/home/tmp/gaorx/lft/20240830/result/TPM"

# # 初始化合并数据框
# merged_data <- NULL

# # 循环读取每个癌肿的基因 TPM 矩阵并合并
# for (cancer in cancer_list) {
#   # 构建文件路径
#   file_path <- file.path(file_path_prefix, cancer, "gene-TPM-matrix.txt")
#   lines <- readLines(file_path)
  
#   # 替换首行的空格为制表符
#   lines[1] <- gsub(" ", "\t", lines[1])  # 用正则表达式替换连续的空格
  
#   # 将修改后的内容写回文件
#   writeLines(lines, file_path)
#   # 读取文件
#   gene_tpm <- read.table(file_path, header = TRUE, sep = "\t")
  
# #   # 按基因合并数据
#   if (is.null(merged_data)) {
#     merged_data <- gene_tpm
#   } else {
#     merged_data <- full_join(merged_data, gene_tpm, by = "gene")
#   }
# }


# # 保存合并后的数据到文件
# write.table(merged_data, file = "/cluster/home/tmp/GBM/HiC/subtype_TCGA/merged_gene_TPM_matrix.txt", sep = "\t", row.names = FALSE, quote = FALSE)

# 02产生coldata
# merged_data <- read.table("/cluster/home/tmp/GBM/HiC/subtype_TCGA/merged_gene_TPM_matrix.txt", header = TRUE, sep = "\t")
# column_names <- colnames(merged_data)[2:9]
# coldata <- data.frame(filename = column_names)
# srr_values <- c("SRR25591312", "SRR25591313", "SRR25591314", "SRR25591306", 
#                 "SRR25591307", "SRR25591308", "SRR12516202", "SRR12516204")
# celltype_values <- c("H4", "H4", "H4", "42MGBA", "42MGBA", "42MGBA", "SW1088", "U118")
# coldata$SRR = srr_values
# coldata$celltype = celltype_values
# # 查看结果
# write.table(coldata, file = "/cluster/home/tmp/GBM/HiC/subtype_TCGA/coldata.txt", sep = "\t", row.names = FALSE, quote = FALSE)


##
install.packages("devtools")
devtools::install_version("readxl", version = "1.0.0")
library(readxl)
ClaNC840=read_excel("/cluster/home/tmp/GBM/HiC/subtype_TCGA/ClaNC840.xlsx")
