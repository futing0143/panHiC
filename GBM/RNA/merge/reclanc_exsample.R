library(aws.s3)
lund <- s3readRDS("lund.rds", "reclanc-lund", region = "us-east-2")
lund
lund$molecular_subtype <- factor(lund$molecular_subtype)
table(lund$molecular_subtype)

library(reclanc)
library(devtools)
rm(list = c("clanc"))

# 这个脚本用 reclanc 确定subtype，relanc修改过，但我忘了怎么改的

# 加载本地修改的包
load_all("/cluster/home/futing/software/reclanc")
# devtools::install("KaiAragaki/reclanc")
install_local("/cluster/home/futing/software/reclanc")

simple_centroids <- clanc(x=lund, classes = "molecular_subtype", active = 5)
head(simple_centroids$centroids)
calculate_pooled_sd
trace("clanc_fit", quote(print("Before running the function")), at = 1)
