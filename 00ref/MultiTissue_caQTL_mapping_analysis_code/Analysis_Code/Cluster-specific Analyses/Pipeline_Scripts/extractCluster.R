library(stringr)

args = commandArgs(trailingOnly=TRUE)

samples <- args[1]
i <- args[2]
path <- args[3]

df2 <- read.table(samples, header = FALSE, stringsAsFactors = FALSE)
df1 <- read.table('/path/to/sample/cpm/file/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.noBL.txt.gz', header = TRUE, stringsAsFactors = FALSE)

final<-df1[df2[[1]]]

write.table(final, paste0(path,"/cluster",i,"/cluster",i,"_CPM_average_noBL.txt"), quote=F, row.names=F, col.names=T, sep="\t")
