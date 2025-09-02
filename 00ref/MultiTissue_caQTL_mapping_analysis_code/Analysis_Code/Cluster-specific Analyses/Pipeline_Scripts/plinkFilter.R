library(admixtools)

args = commandArgs(trailingOnly=TRUE)

samples <- args[1]
clusterNum <- args[2]
path <- args[3]

samples <- read.table(samples,header=F)

individuals <- samples$V1

filtered <- extract_samples("/path/to/genotype/results",paste0(path,"/cluster",clusterNum,"/genotype/cluster",clusterNum,"_plink"),inds=individuals)

