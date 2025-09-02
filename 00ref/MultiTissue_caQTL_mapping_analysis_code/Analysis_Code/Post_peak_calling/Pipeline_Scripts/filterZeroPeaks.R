library(dplyr)

zeroCounts <- read.table("/path/to/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.noAverage.featureZeroCountsWithFeatInfo.txt",header=T)


zeroCountsFilt <- zeroCounts %>% dplyr::filter(zeroes <5000)

peaks_toFilter <- read.table(“all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.txt”,header=T)


peaks_toFilter_final <- peaks_toFilter %>% dplyr::filter(Peak %in% zeroCountsFilt$x.Peak)

#write to file
write.table(peaks_toFilter_final,”all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.noBL.txt”,col.names=T,row.names=F,quote=F,sep=“\t”)
