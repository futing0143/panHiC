#读入原始Counts(cts);
gtf = as.data.frame(rtracklayer::import("/Users/zjl/Desktop/BioSoft&code/genome/gencode.v38.annotation.gtf")) 
gtf_filter = dplyr::select(gtf,c("gene_id","gene_name","gene_type"))
gtf_filter = gtf_filter[!duplicated(gtf_filter$gene_id),]

TPM_gbm <- read.table("gene-TPM-matrix_gbm.txt",header=T)
colnames(TPM_gbm)[1]="gene_id"
gbm_full = merge(gtf_filter,TPM_gbm,by="gene_id")
gbm=gbm_full[,c(2,4:11)]
gbm_mean=aggregate(.~gene_name,mean,data=gbm)
rownames(gbm_mean) = gbm_mean$gene_name
gbm_mean=gbm_mean[,c(2:4,7:9)]
gbm_mean$mean=rowMeans(gbm_mean, na.rm=TRUE)
gbm_mean$ts543_shctl=row.names(gbm_mean)
gbm_final=gbm_mean[,c(1,7)]
write.table(gbm_final,"gbm_PN.txt",sep = "\t")

