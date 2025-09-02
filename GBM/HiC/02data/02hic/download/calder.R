install.packages(path_to_CALDER, repos = NULL, type="source")

if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install("GenomicRanges")
install.packages("remotes")
#remotes::install_github("CSOgroup/CALDER")
remotes::install_github("CSOgroup/CALDER2.0",force = TRUE)

library(strawr)
library(CALDER)
library(data.table)
library(R.utils)
library(doParallel)
library(ape)
library(dendextend)
library(fitdistrplus)
library(igraph)
library(Matrix)
library(rARPACK)
library(factoextra)
library(maptools)
library(fields)
#install.packages(".", repos = NULL, type="source")
#chrs = c(as.character(1:22))
#hic_file = '../mcoolfile/GBM.hic' ## can be downloaded from https://ftp.ncbi.nlm.nih.gov/geo/series/GSE63nnn/GSE63525/suppl/GSE63525_HMEC_combined_30.hic
#  save_dir="./sub-cmpt/gbm"
    
"CALDER(contact_file_hic=hic_file, 
       chrs=chrs, 
       bin_size=5E3,
       genome='hg38',
       save_dir=save_dir,
       save_intermediate_data=FALSE,
       n_cores=2,
       sub_domains=FALSE)"
  setwd("/cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile")
  chrs = c(1:22,"X")
## demo contact matrices in dump format
for (i in c("gsc","NHA", "NPC", "pGBM", "GBM", "SKNSH", "WTC")){
#  for (i in c("GBM")){
a= paste("/cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile",i,sep='/')
setwd(dir=a)
 contact_file_dump = as.list(path=".",sprintf("chr%s.KRobserved.gz", chrs))
  names(contact_file_dump) = chrs
  save_dir="./"
CALDER(contact_file_dump=contact_file_dump, 
         chrs=chrs, 
         bin_size=100E3,
         genome='hg38',
         save_dir=save_dir,
         save_intermediate_data=FALSE,
         n_cores=2,
         sub_domains=FALSE)

  }



setwd(dir="/cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/SKNSH")
contact_file_dump = as.list(path=".",sprintf("chr%s.KRobserved.gz", chrs))
names(contact_file_dump) = chrs
#contact_tab_dump = lapply(contact_file_dump, data.table::fread)
  ## Run CALDER to compute compartments but not nested sub-domains
  CALDER(contact_file_dump=contact_file_dump, 
         chrs=chrs, 
         bin_size=100E3,
         genome='hg38',
         save_dir=save_dir,
         save_intermediate_data=FALSE,
         n_cores=2,
         sub_domains=FALSE)
head("")
