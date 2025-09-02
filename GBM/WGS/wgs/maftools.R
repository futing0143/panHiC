library(maftools)
#setwd("/cluster/home/haojie/data/ding/data0426/wes/")
setwd("/cluster/home/jialu/GBM/WGS")
filename = read.table("wgs.list",header = F)
filename =filename[,1]
#filename2 = read.table("/cluster/home/haojie/data/mi/data0223_second/result_wes/mutec_v2.1.list",header = F)
#filename2 =filename2[,3]
#filename = c(filename,filename2)

setwd("maf/")
maf_file_list = list()
for (i in filename) {
  maffile_name = paste0(i,".maf")
  data = read.csv(maffile_name,header = T,sep = "\t")
  data$Tumor_Sample_Barcode = i
  maf_file_list[[i]] = data
}

var_maf = merge_mafs(maf_file_list)
write.mafSummary(var_maf,"GBM.maf")
