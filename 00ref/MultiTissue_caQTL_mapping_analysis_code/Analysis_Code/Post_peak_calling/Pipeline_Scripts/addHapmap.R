# addHapmap.R

x<-read.table("all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.txt",header=T)
y<-read.table("hapmapSamples_CPM_10.21.22.txt",header=T)

final<-cbind(x,y)

write.table(final,"all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.txt", quote=F, row.names=F, col.names=T, sep="\t")
