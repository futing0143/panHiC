library(reclanc)
library(SummarizedExperiment)
library(parsnip)
library(aws.s3)

# 00 example
lund <- s3readRDS("lund.rds", "reclanc-lund", region = "us-east-2")
lund
lund$molecular_subtype <- factor(lund$molecular_subtype)
table(lund$molecular_subtype)
simple_centroids <- clanc(x=lund, classes = "molecular_subtype", active = 5)
head(simple_centroids$centroids)


# 01 
library(reclanc)
library(devtools)
rm(list = c("clanc"))
# 加载本地修改的包
load_all("/cluster/home/futing/software/reclanc")
# devtools::install("KaiAragaki/reclanc")
install_local("/cluster/home/futing/software/reclanc")
calculate_pooled_sd # 修改了这个函数
trace("clanc_fit", quote(print("Before running the function")), at = 1)

# calculate_pooled_sd <- function(expression, class_data, classes) {
#   df <- nrow(expression) - nrow(class_data)
#   #sum_sq_diffs <- tapply(data.frame(expression), classes, sum_sq_diff)
#   sum_sq_diffs <- apply(expression, 2, function(col) {
#     tapply(col, classes, sum_sq_diff)
#   })
#   sum_sq_diffs <- do.call(rbind, sum_sq_diffs)
#   out <- sqrt(colSums(sum_sq_diffs / df))
#   names(out) <- colnames(expression)
#   out
# }

# sum_sq_diff <- function(exp) {
#   colSums(scale(exp, center = TRUE, scale = FALSE)^2)
# }

# 03 tcga centroids
tcga_all=read_excel('/cluster/home/futing/Project/GBM/RNA/subtype_TPM/centroid/TCGA_unified_CORE_ClaNC840.xlsx')
tcga=read_xls('/cluster/home/futing/Project/GBM/HiC/subtype_TCGA/ClaNC840_centroids_clean.xls')

tcga_all=tcga_all[!is.na(tcga_all$CLID),] %>% as.data.frame()
rownames(tcga_all)=tcga_all$CLID
rowmeta=tcga_all[,c(1,2)]%>% as.data.frame()

subtype_tcga=tcga_all[1,-c(1,2)]%>% t() %>% as.vector()#存metadata
subtype_tcga=factor(subtype_tcga,levels=unique(subtype_tcga))
tcga_all=tcga_all[-1,-c(1,2)]

# 准备input synthetic_expression
synthetic_expression=list(expression=tcga_all,classes=subtype_tcga)
synthetic_expression$expression=apply(synthetic_expression$expression,2,as.numeric)
rownames(synthetic_expression$expression)=rowmeta[-1,1]

# 方法一
form_data <- cbind(
  class = synthetic_expression$classes,
  as.data.frame(t(synthetic_expression$expression))
)

clanc(class ~ ., form_data, active = 5)
discrim_linear() |>
  set_engine("clanc", active = 5) |>
  fit(class ~ ., data = form_data)

# 方法二
clanc(
  synthetic_expression$expression,
  classes = synthetic_expression$classes,
  active = 5
)

# 方法三
se <- SummarizedExperiment(
  synthetic_expression$expression,
  colData = DataFrame(class = synthetic_expression$classes)
)


# --- 04 running fit
fit <- clanc(
  se,
  classes = "class",
  active = 20,
  assay = 1 # Index of assay - SummarizedExperiments only
)
fit
# lapply(synthetic_expression, head) # dummy data
# centroids <- clanc(
#   synthetic_expression$expression,
#   classes = synthetic_expression$classes,
#   active = 5
# )
# centroids


# ----- 05 predicting
# 输入 行是样本，列是基因
ne= SummarizedExperiment(
  t(dat)
)
f=predict(fit, new_data = ne, type = "numeric", method = "spearman")
clanc <- apply(f, 1, function(x) {
  max_col <- colnames(f)[which.max(x)]
  strsplit(as.character(max_col), ".pred_")[[1]][2]
})

clancdf=data.frame(sample=rownames(dat),clanc=clanc)



