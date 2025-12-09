# discarded

library(edgeR)

count <- merge(input, genenames[, c('value', 'SYMBOL')], by.x = 0, by.y = 'value') %>%
  dplyr::select(-1) %>%
  dplyr::select(ncol(.), everything()) %>%
  as_tibble() %>%
  group_by(SYMBOL) %>%
  summarise(
    across(where(is.numeric), \(x) sum(x, na.rm = TRUE)),
    .groups = "drop"
  )
# 创建DGEList对象
dge <- DGEList(counts = count, genes = data.frame(
  GeneID = count$SYMBOL,
  Length = matrix$GeneLen #还是需要geneLen
))

# 计算RPKM/FPKM（需要基因长度）
rpkm <- rpkm(dge, gene.length = "Length", log = FALSE)

# 或者计算TPM（需要先计算RPKM再转换）
# TPM = RPKM / sum(RPKM) * 1e6
tpm <- rpkm / colSums(rpkm) * 1e6

TPM_feature <- as.data.frame(tpm)
TPM_feature <- cbind(GeneID = matrix3[,1], TPM_feature)