#######################################################
#################SUPPLEMENTARY FIGURES#################
#######################################################




##########################################################
#####Supplementary Figure 1 - Genotyping Benchmarking#####
##########################################################

library(tidyverse)
library(reshape2)
library(ggplot2)
library(viridis)
library(cowplot)
library(dplyr)
# detach("package:reshape2", unload=TRUE)

setwd("~/Desktop/Variant_calling")
files = list.files('data/Performance')
files = files[grepl('Overall_performance', files)]
files = files[!grepl('byCategory', files)]
files = files[!grepl('Gencove', files)]

dat = NULL
for(f in files){
  print(f)
  dt = read.table(paste0('data/Performance/', f), sep='\t', header=T)
  dat = rbind(dat, dt)
}

dt = read.table('data/Performance/Overall_performance_Gencove.txt', sep='\t', header=T)
for(minDP in seq(2, 10)){
  dt$minDP = minDP
  dat = rbind(dat, dt)
}
dat = dat[dat$method != 'Imputed_dosage', ]
dat = dat[dat$method != 'Dosage', ]

dat$method = factor(dat$method, levels = c("GC", "Imputation", 
                                           "Y_linear_regression", "Y_logistic_regression", "Y_ordinal_regression", "Y_random_forest",
                                           "Gencove", "Gencove_noQC"),
                    labels = c("GATK genotype caller", "GATK genotype caller + Imputation", 
                               "GATK genotype caller + Imputation combined using linear regression model", "GATK genotype caller + Imputation combined using logistic regression model", 
                               "GATK genotype caller + Imputation combined using ordinal regression model", "GATK genotype caller + Imputation combined using random forest model", "Gencove", "Gencove_noQC"))


# Compare the integration methods
median = dat %>% group_by(method, minDP) %>% summarise(median = median(correlation))
sde = dat %>% group_by(method, minDP) %>% summarise(sde = sd(correlation))

median_sed = merge(median, sde, by = c("method", "minDP"))
median_sed = median_sed[median_sed$method != 'Gencove', ]
median_sed = median_sed[median_sed$method != 'Gencove_noQC', ]

g_metrics = ggplot(data = median_sed, aes(x = minDP, y=median, color = method)) +
  geom_point()+
  geom_line()+
  xlab('Minimum reads per locus for genotype caller') +
  ylab('Spearman correlation') +
  guides(fill=guide_legend(title="Method")) +
  theme_bw() +
  #geom_ribbon(aes(ymax = median + sde, ymin = median - sde,  fill = method), alpha = 0.3, color = "NA") +
  guides(fill = FALSE) +
  ylim(0.7, 1.0)

ggsave(paste0("results/Sup_fig_1A.png"), g_metrics, height = 2.5, width = 10.5)


# Compare the four methods

dat = NULL
for(f in files){
  print(f)
  dt = read.table(paste0('data/Performance/', f), sep='\t', header=T)
  dat = rbind(dat, dt)
}

dt = read.table('data/Performance/Overall_performance_Gencove.txt', sep='\t', header=T)
for(minDP in seq(2, 10)){
  dt$minDP = minDP
  dat = rbind(dat, dt)
}

dat = dat[dat$method != 'Imputed_dosage', ]
dat = dat[dat$method != 'Dosage', ]
dat = dat[dat$method != 'Y_linear_regression', ]
dat = dat[dat$method != 'Y_logistic_regression', ]
dat = dat[dat$method != 'Y_ordinal_regression', ]
dat = dat[dat$method != 'Gencove_noQC', ]
dat$method = factor(dat$method, levels = c("GC", "Imputation", "Y_random_forest","Gencove"),
                    labels = c("GATK Genotype caller", "GATK Genotype caller + Imputation", "GATK genotype caller + Imputation combined using random forest model","Gencove"))


# Number of variants
dat_number = dat[,c("sample", "minDP", "Number", "method")]

dat_number = dat_number[!duplicated(dat_number),]
median = dat_number %>% group_by(method, minDP) %>% summarise(median = median(Number))
sde = dat_number %>% group_by(method, minDP) %>% summarise(sde = sd(Number))

median_sed = merge(median, sde, by = c("method", "minDP"))
g_metrics = ggplot(data = median_sed, aes(x = minDP, y=median, color = method)) +
  geom_point()+
  geom_line()+
  xlab('Minimum reads per locus for genotype caller') +
  ylab('Number of called variants') +
  #scale_color_manual(values = c("red", "blue", "green", "darkblue", "purple")) + 
  scale_color_viridis(discrete = TRUE) +
  #scale_fill_viridis(discrete = TRUE)+
  guides(fill=guide_legend(title="Method")) +
  theme_bw() +
  #geom_ribbon(aes(ymax = median + sde, ymin = median - sde,  fill = method), alpha = 0.3, color = "NA") +
  guides(fill = FALSE) +
  theme(legend.position="none")

ggsave(paste0("results/Sup_fig_1C.png"), g_metrics, height = 2.5, width = 5)


# Spearman correlation
median = dat %>% group_by(method, minDP) %>% summarise(median = median(correlation))
sde = dat %>% group_by(method, minDP) %>% summarise(sde = sd(correlation))

median_sed = merge(median, sde, by = c("method", "minDP"))

g_metrics = ggplot(data = median_sed, aes(x = minDP, y=median, color = method)) +
  geom_point()+
  geom_line()+
  xlab('Minimum reads per locus for genotype caller') +
  ylab('Spearman correlation') +
  scale_color_viridis(discrete = TRUE) +
  #scale_fill_viridis(discrete = TRUE)+
  #scale_color_manual(values = c("red", "blue", "green", "purple")) + 
  guides(fill=guide_legend(title="Method")) +
  theme_bw() +
  #geom_ribbon(aes(ymax = median + sde, ymin = median - sde,  fill = method), alpha = 0.3, color = "NA") +
  guides(fill = FALSE) +
  ylim(0.7, 1.0)+
  theme(legend.position="none")

ggsave(paste0("results/Sup_fig_1B.png"), g_metrics, height = 2.5, width = 5.5)





#######################################################
#####Supplementary Figure 2 - Sample metadata plot#####
#######################################################

#load packages
library(data.table)
library(ggplot2)
library(dplyr)
library(tidyverse)

#read in data
metadata <- fread("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.clusterAnalyses/uniqueDonors_metadata.txt",header=T)
colnames(metadata) <- gsub(" ","_",colnames(metadata))
colnames(metadata) <- gsub("/","_",colnames(metadata))




metadata %>% group_by(Combined_Tissue_Cell_Type) %>% count %>% filter(n > 0) %>% arrange(desc(n)) %>% ggplot(aes(x = reorder(Combined_Tissue_Cell_Type, n), y = n)) + geom_bar(stat = "identity",color="darkblue", fill="lightblue") + theme(text = element_text(size = 7),axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + xlab("Tissue/Cell") + ylab("Count") +  coord_flip()

ggsave("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Figures/Supplementary_all_unique_qtlmapping_samples_metadata.png")



#grab relevant columns
metadata_toPlot <- data.frame(metadata$Combined_Tissue_Cell_Type,metadata$Cancer,metadata$Cell_Line,metadata$Primary_Tissue,metadata$Differentiated)
colnames(metadata_toPlot) <- c("Type","Cancer","Cell_Line","Primary","Differentiated")

#ggplot stacked barplot
df_forPlot <- metadata_toPlot %>% pivot_longer(-Type)

ggplot(df_forPlot, aes(name)) + geom_bar(aes(fill = value))

ggsave("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Figures/Supplementary_all_unique_qtlmapping_samples_stackedBarplots_sampleAttributes.png")  


################################################################################
#####Supplementary Figure 3 - Peak Length Distribution - Call/Merge Strategy####
################################################################################



library(ggplot2)
library(data.table)


peaks <- fread("all_peak_above50_samples.sorted.final.bed",header=T)
peaks$length <- peaks$End-peaks$Start


ggplot(peaks, aes(x=length))+ geom_histogram(color="darkblue", fill="lightblue",bins=500) + xlim(0,4000) + xlab("Peak Length (bp)") + ylab("Counts") + theme_bw() + theme(text=element_text(size=28))

ggsave("all_peak_above50_samples.sorted.final.peakLengths.png",height=8,width=12)




##################################################################################
#####Supplementary Figure 4 - All ATAC-seq peaks genome annotation enrichment#####
##################################################################################

library(data.table)
library(dplyr)
library(annotatr)
library(stringr)

#read in regions of interest
y<-read_regions(con=paste0("/home/bwenz/yuanAllSamples_3.22.22/YuanAllSamples_Genrich/newPeakBLremoved/blackListRemoved.peakCoords.withChr.bed"),genome='hg38')


annots = c("hg38_genes_1to5kb","hg38_genes_promoters","hg38_genes_cds","hg38_genes_5UTRs","hg38_genes_exons","hg38_genes_firstexons","hg38_genes_introns","hg38_genes_intronexonboundaries","hg38_genes_3UTRs","hg38_genes_intergenic","hg38_enhancers_fantom","hg38_basicgenes")

# Build the annotations (a single GRanges object)
annotations = build_annotations(genome = 'hg38', annotations = annots)

# Intersect the regions we read in with the annotations
y_annotated = annotate_regions(
  regions = y,
  annotations = annotations,
  ignore.strand = TRUE,
  quiet = FALSE,minoverlap =100)

# A GRanges object is returned
#print(y_annotated)



df_dm_annotated = data.frame(y_annotated)

dm_annsum = summarize_annotations(
  annotated_regions = y_annotated,
  quiet = TRUE)
write.table(dm_annsum,"/home/bwenz/yuanAllSamples_3.22.22/YuanAllSamples_Genrich/newPeakBLremoved/blackListRemoved.allPeaks_peakAnnotations.txt")


dm_annotated<-read.table("/home/bwenz/yuanAllSamples_3.22.22/YuanAllSamples_Genrich/newPeakBLremoved/blackListRemoved.allPeaks_peakAnnotations.txt")

annots_order = c("hg38_genes_1to5kb","hg38_genes_promoters","hg38_genes_cds","hg38_genes_5UTRs","hg38_genes_exons","hg38_genes_firstexons","hg38_genes_introns","hg38_genes_intronexonboundaries","hg38_genes_3UTRs","hg38_genes_intergenic","hg38_enhancers_fantom","hg38_basicgenes")

randomDF<-data.frame(dm_annotated$annot.type)
for (x in (1:100)){
  # Randomize the input regions
  dm_random_regions = randomize_regions(regions = y,allow.overlaps = TRUE,per.chromosome = TRUE)
  
  # Annotate the random regions using the same annotations as above
  # These will be used in later functions
  dm_random_annotated = annotate_regions(regions = dm_random_regions,annotations = annotations,ignore.strand = TRUE,quiet = TRUE,minoverlap =100)
  
  df_dm_random_annotated = data.frame(dm_random_annotated)
  
  dm_annsum_random = summarize_annotations(annotated_regions = dm_random_annotated,quiet = TRUE)
  
  dm_annsum_random<-as.data.frame(dm_annsum_random)
  
  randomDF<-merge(randomDF,dm_annsum_random,by.x='dm_annotated.annot.type',by.y='annot.type',all=T)
  
}  


finalDF<-merge(randomDF,dm_annotated,by.x="dm_annotated.annot.type",by.y="annot.type",all=T)
colnames(finalDF)<-c("Annotation",paste0("Random_",rep(1:100)),"ATAC_Peak_Regions")

#get number of shuffled values greater than real values
for (q in 1:nrow(finalDF)){
  
  pValCount <- sum(colSums(finalDF[q,2:101] >= finalDF[q,102]))
  
  if (pValCount == 0){
    finalDF$pval[q] <- 1/101
  }else{
    finalDF$pval[q] <- pValCount/100
  }
  
}


finalDF<-as.data.frame(finalDF)
finalDF[is.na(finalDF)] <- 0
finalDF$RandomMedian <- apply(finalDF[,2:101],1,median)

write.table(finalDF,"/home/bwenz/yuanAllSamples_3.22.22/YuanAllSamples_Genrich/newPeakBLremoved/blackListRemoved.allPeaks_peakAnnotations.realRegions_vs_random_1000iterations.txt",col.names=T,row.names=F,quote=F,sep='\t')

finalDF_mod <- data.frame(finalDF$Annotation,finalDF$RandomMedian,finalDF$ATAC_Peak_Regions,finalDF$pval)
colnames(finalDF_mod) <- c("Annotation","Random","caQTL_Peak","pval")
finalDF <- finalDF_mod

write.table(finalDF,"/home/bwenz/yuanAllSamples_3.22.22/YuanAllSamples_Genrich/newPeakBLremoved/blackListRemoved.allPeaks_peakAnnotations.realRegions_vs_random_1000iterations.stats.txt",col.names=T,row.names=F,quote=F,sep='\t')

library(reshape)

finalDF2 <- data.frame(finalDF$Annotation,finalDF$ATAC_Peak_Regions,finalDF$RandomMedian)
colnames(finalDF2) <- c("Annotation","ATAC_Peak_Regions","RandomMedian")

dfForPlot<-melt(finalDF2, id=c("Annotation"))
dfForPlot<-as.data.frame(dfForPlot)
colnames(dfForPlot)<-c("Annotation","Set","RegionCount")
dfForPlot$RegionCount<-as.character(dfForPlot$RegionCount)
dfForPlot$RegionCount<-as.numeric(dfForPlot$RegionCount)

library(ggplot2)

p=ggplot(dfForPlot,aes(x=Annotation,y=RegionCount,fill=Set)) +  geom_bar(stat="identity",position="dodge") + ylab("count")+ theme_bw()+ theme(plot.title = element_text( size=12, face="bold.italic"),axis.title.y = element_text( size=10, face="bold"), axis.text.x = element_text(face="bold", size=8),axis.text.y = element_text(face="bold", size=8)) + theme(axis.text.x = element_text(angle = 45, hjust=1)) + theme(legend.title = element_text(size = 8),legend.text = element_text(size = 8))+theme(plot.margin = margin(1,1,1.5,1.2, "cm")) + ggtitle("All Peak Genome Annotations")

ggsave("blackListRemoved.allPeaks_peakAnnotations_GenomeAnnotations_vsRandom.10.15.24.png",p,width=5,height=5,dpi=1200)





#########################################################################
#####Supplementary Figure 5,6 - Cancer vs. non-cancer caQTL Overlap######
#########################################################################

library(data.table)
library(ggplot2)
library(dplyr)
library(ggvenn)
library(eulerr)
library(qvalue)

#read in results
pc_200 <- fread("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/tensorQTL/10.9.24_analyses/tensorQTL_results/tensorqtl_yuanAllSamples_10.9.24_prinComp200_allChr.cis_qtl.txt.gz")

non_cancer <- fread("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/manuscript_review_analyses/non_cancer_samples_qtlAnalyses/prinComp_100/tensorqtl_noncancerSamples_prinComp100_allChr_10.7.24.cis_qtl.txt.gz")

cancer_samples <- fread("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.clusterAnalyses/cancer_samples_analyses/prinComp_35/tensorqtl_cancerSamples_prinComp35_allChr_10.14.24.cis_qtl.txt.gz")

#filter to fdr5
pc_200_filt <- pc_200 %>% dplyr::filter(qval <= 0.05)
non_cancer_filt <- non_cancer %>% dplyr::filter(qval <= 0.05)
cancer_samples_filt <- cancer_samples %>% dplyr::filter(qval <= 0.05)


#get overlap
dim(pc_200_filt)
#[1] 24159    19

dim(non_cancer_filt)
#[1] 21422    19

dim(cancer_samples_filt)
#[1] 3434   19

length(intersect(pc_200_filt$phenotype_id,non_cancer_filt$phenotype_id))
#[1] 16234
#16234/21422 = 0.6719649

length(intersect(pc_200_filt$phenotype_id,cancer_samples_filt$phenotype_id))
#[1] 3178
#3178
#3178/3434 = 0.93

#venn diagram
caqtlOverlapList <- list(Global=unique(pc_200_filt$phenotype_id),Cancer=unique(cancer_samples_filt$phenotype_id),"Non-cancer"=unique(non_cancer_filt$phenotype_id))
fit <- euler(caqtlOverlapList)

png("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/manuscript_review_analyses/cancer_noncancer_allSamples_comparison/pc_200_vs_cancer_vs_noncancer_caqtl_overlap.png",height=8,width=12,units="in",res=400)
plot(fit,quantities = TRUE,fill=c("#fc8d59", "#ffffbf","#91cf60"),main="FDR5 caQTL Peaks Identified",legend=T)
dev.off()

#get pi1 overlap

#add all cis nominal results to df
pc200_allResults <- data.frame()
for (i in (1:22)){
  df <- fread(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/tensorQTL/10.9.24_analyses/tensorQTL_results/tensorqtl_yuanAllSamples_10.9.24_prinComp200_allChr.cisNominal.cis_qtl_pairs.",i,".txt"))
  pc200_allResults <- rbind(pc200_allResults,df)
}

#filter based on peaks in cancer runs
pc200_allResults_cancer_peaks <- pc200_allResults %>% dplyr::filter(phenotype_id %in% cancer_samples_filt$phenotype_id)

#make unique column to match on 
pc200_allResults_cancer_peaks$uniq <- paste0(pc200_allResults_cancer_peaks$phenotype_id,"_",pc200_allResults_cancer_peaks$variant_id)
cancer_samples_filt$uniq <- paste0(cancer_samples_filt$phenotype_id,"_",cancer_samples_filt$variant_id)

#get merged df
merged <- merge(pc200_allResults_cancer_peaks,cancer_samples_filt,by="uniq")

#get pi1
pi1 = 1 - qvalue::qvalue(merged$pval_nominal.x)$pi0

pi1
#0.9863278

#plot p value distribution
ggplot(merged, aes(x=pval_nominal.x))+ geom_histogram(color="darkblue", fill="lightblue") + ggtitle("Global p-values in Cancer Sample Analysis caQTL Peaks") + xlab("Nominal p-value") + theme(text = element_text(size = 18))
ggsave("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/manuscript_review_analyses/cancer_noncancer_allSamples_comparison/cancer_caQTL_peaks_pc_200_replication_pvals.png",height=10,width=12)


#filter based on peaks in non_cancer run
pc200_allResults_noncancer_peaks <- pc200_allResults %>% dplyr::filter(phenotype_id %in% non_cancer_filt$phenotype_id)

#make unique column to match on 
pc200_allResults_noncancer_peaks$uniq <- paste0(pc200_allResults_noncancer_peaks$phenotype_id,"_",pc200_allResults_noncancer_peaks$variant_id)
non_cancer_filt$uniq <- paste0(non_cancer_filt$phenotype_id,"_",non_cancer_filt$variant_id)

#get merged df
merged <- merge(pc200_allResults_noncancer_peaks,non_cancer_filt,by="uniq")

#get pi1
pi1 = 1 - qvalue::qvalue(merged$pval_nominal.x)$pi0

pi1
#[1] 0.9977377

#plot p value distribution
ggplot(merged, aes(x=pval_nominal.x))+ geom_histogram(color="darkblue", fill="lightblue") + ggtitle("Global p-values in Non-Cancer Sample Analysis caQTL Peaks") + theme(text = element_text(size = 18)) + xlab("Nominal p-value")
ggsave("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/manuscript_review_analyses/cancer_noncancer_allSamples_comparison/noncancer_caQTL_peaks_pc_200_replication_pvals.png",height=10,width=12)


#check for cancer and noncancer pi1 with each other and Global
#add all cis nominal results to df
cancer_allResults <- data.frame()
for (i in (1:22)){
  df <- fread(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.clusterAnalyses/cancer_samples_analyses/prinComp_35/tensorqtl_cancerSamples_prinComp35_cisNominal_allChr_10.14.24.cis_qtl_pairs.",i,".txt"))
  cancer_allResults <- rbind(cancer_allResults,df)
}


noncancer_allResults <- data.frame()
for (i in (1:22)){
  df <- fread(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/manuscript_review_analyses/non_cancer_samples_qtlAnalyses/prinComp_100/tensorqtl_noncancerSamples_prinComp100_allChr_10.7.24_cisNominal.cis_qtl_pairs.",i,".txt"))
  noncancer_allResults <- rbind(noncancer_allResults,df)
}



#filter non cancer results based on peaks in Global run
noncancer_allResults_pc200_peaks <- noncancer_allResults %>% dplyr::filter(phenotype_id %in% pc_200_filt$phenotype_id)

#make unique column to match on 
noncancer_allResults_pc200_peaks$uniq <- paste0(noncancer_allResults_pc200_peaks$phenotype_id,"_",noncancer_allResults_pc200_peaks$variant_id)
pc_200_filt$uniq <- paste0(pc_200_filt$phenotype_id,"_",pc_200_filt$variant_id)

#get merged df
merged <- merge(noncancer_allResults_pc200_peaks,pc_200_filt,by="uniq")

#get pi1
pi1 = 1 - qvalue::qvalue(merged$pval_nominal.x)$pi0

pi1
#[1] 0.9977377

#plot p value distribution
ggplot(merged, aes(x=pval_nominal.x))+ geom_histogram(color="darkblue", fill="lightblue") + ggtitle("Non-cancer Samples p-values in Global Analysis caQTL Peaks") + theme(text = element_text(size = 18)) + xlab("Nominal p-value")
ggsave("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/manuscript_review_analyses/cancer_noncancer_allSamples_comparison/allSamples_caQTL_peaks_nonCancer_replication_pvals.png",height=10,width=12)



#filter cancer results based on peaks in Global run
cancer_allResults_pc200_peaks <- cancer_allResults %>% dplyr::filter(phenotype_id %in% pc_200_filt$phenotype_id)

#make unique column to match on 
cancer_allResults_pc200_peaks$uniq <- paste0(cancer_allResults_pc200_peaks$phenotype_id,"_",cancer_allResults_pc200_peaks$variant_id)
pc_200_filt$uniq <- paste0(pc_200_filt$phenotype_id,"_",pc_200_filt$variant_id)

#get merged df
merged <- merge(cancer_allResults_pc200_peaks,pc_200_filt,by="uniq")

#get pi1
pi1 = 1 - qvalue::qvalue(merged$pval_nominal.x)$pi0

pi1
#[1] 0.9014208


#plot p value distribution
ggplot(merged, aes(x=pval_nominal.x))+ geom_histogram(color="darkblue", fill="lightblue") + ggtitle("Cancer Samples p-values in Global Analysis caQTL Peaks") + theme(text = element_text(size = 18)) + xlab("Nominal p-value")
ggsave("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/manuscript_review_analyses/cancer_noncancer_allSamples_comparison/allSamples_caQTL_peaks_Cancer_replication_pvals.png",height=10,width=12)



#filter cancer results based on peaks in noncancer samples run
cancer_allResults_noncancer_peaks <- cancer_allResults %>% dplyr::filter(phenotype_id %in% non_cancer_filt$phenotype_id)

#make unique column to match on 
cancer_allResults_noncancer_peaks$uniq <- paste0(cancer_allResults_noncancer_peaks$phenotype_id,"_",cancer_allResults_noncancer_peaks$variant_id)
non_cancer_filt$uniq <- paste0(non_cancer_filt$phenotype_id,"_",non_cancer_filt$variant_id)

#get merged df
merged <- merge(cancer_allResults_noncancer_peaks,non_cancer_filt,by="uniq")

#get pi1
pi1 = 1 - qvalue::qvalue(merged$pval_nominal.x)$pi0

pi1
#[1] 0.6253217

#plot p value distribution
ggplot(merged, aes(x=pval_nominal.x))+ geom_histogram(color="darkblue", fill="lightblue") + ggtitle("Cancer Samples p-values in Non-cancer Samples Analysis caQTL Peaks") + theme(text = element_text(size = 18))+ xlab("Nominal p-value")
ggsave("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/manuscript_review_analyses/cancer_noncancer_allSamples_comparison/nonCancer_Samples_caQTL_peaks_Cancer_replication_pvals.png",height =10, width=12)


#filter non cancer results based on peaks in cancer samples run
noncancer_allResults_cancer_peaks <- noncancer_allResults %>% dplyr::filter(phenotype_id %in% cancer_samples_filt$phenotype_id)

#make unique column to match on 
noncancer_allResults_cancer_peaks$uniq <- paste0(noncancer_allResults_cancer_peaks$phenotype_id,"_",noncancer_allResults_cancer_peaks$variant_id)
cancer_samples_filt$uniq <- paste0(cancer_samples_filt$phenotype_id,"_",cancer_samples_filt$variant_id)

#get merged df
merged <- merge(noncancer_allResults_cancer_peaks,cancer_samples_filt,by="uniq")

#get pi1
pi1 = 1 - qvalue::qvalue(merged$pval_nominal.x)$pi0

pi1
#[1] 0.9424195


#plot p value distribution
ggplot(merged, aes(x=pval_nominal.x))+ geom_histogram(color="darkblue", fill="lightblue") + ggtitle("Non-cancer Samples p-values in Cancer Samples Analysis caQTL Peaks")+ theme(text = element_text(size = 18))+ xlab("Nominal p-value")
ggsave("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/manuscript_review_analyses/cancer_noncancer_allSamples_comparison/cancerSamples_caQTL_peaks_nonCancer_replication_pvals.png",height=10,width=12)




###########################################################################
#####Supplementary Figure 7,8 - Blood vs. Brain Samples caQTL Overlap######
###########################################################################

library(data.table)
library(ggplot2)
library(dplyr)
library(ggvenn)
library(eulerr)
library(qvalue)

#read in results
pc_200 <- fread("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/tensorQTL/10.9.24_analyses/tensorQTL_results/tensorqtl_yuanAllSamples_10.9.24_prinComp200_allChr.cis_qtl.txt.gz")

brain <- fread("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/manuscript_review_analyses/brain_samples_caqtl_analyses/prinComp_120/tensorqtl_brainSamples_prinComp120_allChr_10.7.24.cis_qtl.txt.gz")

blood_samples <- fread("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/manuscript_review_analyses/blood_samples_caqtl_analyses/prinComp_13/tensorqtl_bloodSamples_prinComp13_allChr_10.7.24.cis_qtl.txt.gz")

#filter to fdr5
pc_200_filt <- pc_200 %>% dplyr::filter(qval <= 0.05)
brain_filt <- brain %>% dplyr::filter(qval <= 0.05)
blood_samples_filt <- blood_samples %>% dplyr::filter(qval <= 0.05)

#get overlap
dim(pc_200_filt)
#[1] 24159    19

dim(brain_filt)
#[1] 7551    19

dim(blood_samples_filt)
#[1] 3736   19

#brain
length(intersect(pc_200_filt$phenotype_id,brain_filt$phenotype_id))
#[1] 2981
#2981/7551 = 0.3947821

#blood
length(intersect(pc_200_filt$phenotype_id,blood_samples_filt$phenotype_id))
#[1] 2445
#2445/3736 = 0.6544433

#venn diagram
caqtlOverlapList <- list(Global=unique(pc_200_filt$phenotype_id),Brain=unique(brain_filt$phenotype_id),"Blood (T cell)"=unique(blood_samples_filt$phenotype_id))
fit <- euler(caqtlOverlapList)

png("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/manuscript_review_analyses/brain_blood_pc200_samples_analysis/pc_200_vs_brain_vs_blood_caqtl_overlap.png",height=8,width=12,units="in",res=400)
plot(fit,quantities = TRUE,fill=c("#fc8d59", "#ffffbf","#91cf60"),main="FDR5 caQTL Peaks Identified",legend=TRUE)
dev.off()

#get pi1 overlap

#add all cis nominal results to df
pc200_allResults <- data.frame()
for (i in (1:22)){
  df <- fread(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/tensorQTL/10.9.24_analyses/tensorQTL_results/tensorqtl_yuanAllSamples_10.9.24_prinComp200_allChr.cisNominal.cis_qtl_pairs.",i,".txt"))
  pc200_allResults <- rbind(pc200_allResults,df)
}

brain_allResults <- data.frame()
for (i in (1:22)){
  df <- fread(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/manuscript_review_analyses/brain_samples_caqtl_analyses/prinComp_120/tensorqtl_brainSamples_prinComp120_allChr_10.7.24_cisNominal.cis_qtl_pairs.",i,".txt"))
  brain_allResults <- rbind(brain_allResults,df)
}

blood_allResults <- data.frame()
for (i in (1:22)){
  df <- fread(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/manuscript_review_analyses/blood_samples_caqtl_analyses/prinComp_13/tensorqtl_bloodSamples_prinComp13_allChr_10.7.24_cisNominal.cis_qtl_pairs.",i,".txt"))
  blood_allResults <- rbind(blood_allResults,df)
}


#filter based on peaks in brain runs
pc200_allResults_brain_peaks <- pc200_allResults %>% dplyr::filter(phenotype_id %in% brain_filt$phenotype_id)

#make unique column to match on 
pc200_allResults_brain_peaks$uniq <- paste0(pc200_allResults_brain_peaks$phenotype_id,"_",pc200_allResults_brain_peaks$variant_id)
brain_filt$uniq <- paste0(brain_filt$phenotype_id,"_",brain_filt$variant_id)

#get merged df
merged <- merge(pc200_allResults_brain_peaks,brain_filt,by="uniq")

#get pi1
pi1 = 1 - qvalue::qvalue(merged$pval_nominal.x)$pi0

pi1
#[1] 0.6686546

#plot p value distribution
ggplot(merged, aes(x=pval_nominal.x))+ geom_histogram(color="darkblue", fill="lightblue") + ggtitle("Global p-values in Brain Sample Analysis caQTL Peaks") + xlab("Nominal p-value") + theme(text = element_text(size = 18))
ggsave("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/manuscript_review_analyses/brain_blood_pc200_samples_analysis/brain_caQTL_peaks_pc_200_replication_pvals.png",height=10,width=12)

####################
#do inverse analysis

#filter brain based on peaks in Global runs
brain_Results_pc200_peaks <- brain_allResults %>% dplyr::filter(phenotype_id %in% pc_200_filt$phenotype_id)

#make unique column to match on 
brain_Results_pc200_peaks$uniq <- paste0(brain_Results_pc200_peaks$phenotype_id,"_",brain_Results_pc200_peaks$variant_id)
pc_200_filt$uniq <- paste0(pc_200_filt$phenotype_id,"_",pc_200_filt$variant_id)

#get merged df
merged <- merge(brain_Results_pc200_peaks,pc_200_filt,by="uniq")

#get pi1
pi1 = 1 - qvalue::qvalue(merged$pval_nominal.x)$pi0

pi1
#[1] 0.6218019

#plot p value distribution
ggplot(merged, aes(x=pval_nominal.x))+ geom_histogram(color="darkblue", fill="lightblue") + ggtitle("Brain Samples p-values in Global Analysis caQTL Peaks")+ xlab("Nominal p-value") + theme(text = element_text(size = 18))
ggsave("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/manuscript_review_analyses/brain_blood_pc200_samples_analysis/allSamples_caQTL_peaks_brain_replication_pvals.png",height=10,width=12)



####blood


#filter based on peaks in blood runs
pc200_allResults_blood_peaks <- pc200_allResults %>% dplyr::filter(phenotype_id %in% blood_samples_filt$phenotype_id)

#make unique column to match on 
pc200_allResults_blood_peaks$uniq <- paste0(pc200_allResults_blood_peaks$phenotype_id,"_",pc200_allResults_blood_peaks$variant_id)
blood_samples_filt$uniq <- paste0(blood_samples_filt$phenotype_id,"_",blood_samples_filt$variant_id)

#get merged df
merged <- merge(pc200_allResults_blood_peaks,blood_samples_filt,by="uniq")

#get pi1
pi1 = 1 - qvalue::qvalue(merged$pval_nominal.x)$pi0

pi1
#[1] 0.8468062

#plot p value distribution
ggplot(merged, aes(x=pval_nominal.x))+ geom_histogram(color="darkblue", fill="lightblue") + ggtitle("Global p-values in Blood Sample Analysis caQTL Peaks")+ xlab("Nominal p-value") + theme(text = element_text(size = 18))
ggsave("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/manuscript_review_analyses/brain_blood_pc200_samples_analysis/blood_caQTL_peaks_pc_200_replication_pvals.png",height=10,width=12)

####################
#do inverse analysis

#filter blood based on peaks in Global runs
blood_Results_pc200_peaks <- blood_allResults %>% dplyr::filter(phenotype_id %in% pc_200_filt$phenotype_id)

#make unique column to match on 
blood_Results_pc200_peaks$uniq <- paste0(blood_Results_pc200_peaks$phenotype_id,"_",blood_Results_pc200_peaks$variant_id)
pc_200_filt$uniq <- paste0(pc_200_filt$phenotype_id,"_",pc_200_filt$variant_id)

#get merged df
merged <- merge(blood_Results_pc200_peaks,pc_200_filt,by="uniq")

#get pi1
pi1 = 1 - qvalue::qvalue(merged$pval_nominal.x)$pi0

pi1
#[1] 0.6471069

#plot p value distribution
ggplot(merged, aes(x=pval_nominal.x))+ geom_histogram(color="darkblue", fill="lightblue") + ggtitle("Blood Samples p-values in Global Analysis caQTL Peaks")+ xlab("Nominal p-value") + theme(text = element_text(size = 18))
ggsave("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/manuscript_review_analyses/brain_blood_pc200_samples_analysis/allSamples_caQTL_peaks_blood_replication_pvals.png",height=10,width=12)



####blood and brain


#filter brain based on peaks in blood runs
brain_allResults_blood_peaks <- brain_allResults %>% dplyr::filter(phenotype_id %in% blood_samples_filt$phenotype_id)

#make unique column to match on 
brain_allResults_blood_peaks$uniq <- paste0(brain_allResults_blood_peaks$phenotype_id,"_",brain_allResults_blood_peaks$variant_id)
blood_samples_filt$uniq <- paste0(blood_samples_filt$phenotype_id,"_",blood_samples_filt$variant_id)

#get merged df
merged <- merge(brain_allResults_blood_peaks,blood_samples_filt,by="uniq")

#get pi1
pi1 = 1 - qvalue::qvalue(merged$pval_nominal.x)$pi0

pi1
#[1] 0.5136508


#plot p value distribution
ggplot(merged, aes(x=pval_nominal.x))+ geom_histogram(color="darkblue", fill="lightblue") + ggtitle("Brain Samples p-values in Blood Sample Analysis caQTL Peaks")+ xlab("Nominal p-value") + theme(text = element_text(size = 18))
ggsave("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/manuscript_review_analyses/brain_blood_pc200_samples_analysis/blood_caQTL_peaks_brain_replication_pvals.png",height=10,width=12)

####################
#do inverse analysis

#filter blood based on peaks in brain samples runs
blood_Results_brain_peaks <- blood_allResults %>% dplyr::filter(phenotype_id %in% brain_filt$phenotype_id)

#make unique column to match on 
blood_Results_brain_peaks$uniq <- paste0(blood_Results_brain_peaks$phenotype_id,"_",blood_Results_brain_peaks$variant_id)
brain_filt$uniq <- paste0(brain_filt$phenotype_id,"_",brain_filt$variant_id)

#get merged df
merged <- merge(blood_Results_pc200_peaks,brain_filt,by="uniq")

#get pi1
pi1 = 1 - qvalue::qvalue(merged$pval_nominal.x)$pi0

pi1
#[1] 0.7055311


#plot p value distribution
ggplot(merged, aes(x=pval_nominal.x))+ geom_histogram(color="darkblue", fill="lightblue") + ggtitle("Blood Samples p-values in Brain Analysis caQTL Peaks")+ xlab("Nominal p-value") + theme(text = element_text(size = 18))
ggsave("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/manuscript_review_analyses/brain_blood_pc200_samples_analysis/brainSamples_caQTL_peaks_blood_replication_pvals.png",height=10,width=12)





################################################################################################
#####Supplementary Figure 9 - Cell type covariate vs. no cell type covariate caQTL Overlap######
################################################################################################

library(data.table)
library(dplyr)
library(ggvenn)
library(eulerr)
library(qvalue)

#read in cell type factor results
cellType <- fread("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/tensorQTL/10.9.24_analyses/cellType_cov_analyses/tensorqtl_yuanAllSamples_10.9.24_prinComp200_cellTypeCov_11.21.24_allChr.cis_qtl.txt.gz")

non_cellType <- fread("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/tensorQTL/10.9.24_analyses/tensorQTL_results/tensorqtl_yuanAllSamples_10.9.24_prinComp200_allChr.cis_qtl.txt.gz")

#filter to get fdr5 cqtls
cellType_filt <- cellType %>% dplyr::filter(qval <= 0.05)
non_cellType_filt <- non_cellType %>% dplyr::filter(qval <= 0.05)

#get dimensions
dim(cellType_filt)
#[1] 23235    19

dim(non_cellType_filt)
#[1] 24159    19

#get length of overlap
length(intersect(cellType_filt$phenotype_id,non_cellType_filt$phenotype_id))
#[1] 21107


#venn diagram - genes
caqtlOverlapList <- list("Cell Type Covariate"=unique(cellType_filt$phenotype_id),"No Cell Type Covariate"=unique(non_cellType_filt$phenotype_id))
fit <- euler(caqtlOverlapList)

png("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/tensorQTL/10.9.24_analyses/cellType_cov_analyses/cellType_cov_vanilla_cov_caQTLpeak_overlap.png",height=8,width=12,units="in",res=400)
plot(fit,quantities = TRUE,fill=c("#f1a340", "#998ec3"),main="FDR5 caQTL Peaks Identified", legend=TRUE)
dev.off()

#add all cis nominal results to df
pc200_allResults <- data.frame()
for (i in (1:22)){
  df <- fread(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/tensorQTL/10.9.24_analyses/tensorQTL_results/tensorqtl_yuanAllSamples_10.9.24_prinComp200_allChr.cisNominal.cis_qtl_pairs.",i,".txt"))
  pc200_allResults <- rbind(pc200_allResults,df)
}


#filter based on peaks in pc580
pc200_allResults_cellType_peaks <- pc200_allResults %>% dplyr::filter(phenotype_id %in% cellType_filt$phenotype_id)

#make unique column to match on 
pc200_allResults_cellType_peaks$uniq <- paste0(pc200_allResults_cellType_peaks$phenotype_id,"_",pc200_allResults_cellType_peaks$variant_id)
cellType_filt$uniq <- paste0(cellType_filt$phenotype_id,"_",cellType_filt$variant_id)

#get merged df
merged <- merge(pc200_allResults_cellType_peaks,cellType_filt,by="uniq")

#get pi1
pi1 = 1 - qvalue::qvalue(merged$pval_nominal.x,lambda=0.1)$pi0

pi1
#[1] 0.9994744

#plot p value distribution
ggplot(merged, aes(x=pval_nominal.x))+ geom_histogram(color="darkblue", fill="lightblue")
ggsave("cellTypeFactor_caQTL_peaks_nonCellTypeFactor_pc_200_replication_pvals.png")





################################################################################
#####Supplementary Figure 10 - FDR5 caQTL peaks genome annotation enrichment#####
################################################################################


library(data.table)
library(dplyr)
library(annotatr)
library(stringr)

#read in regions of interest
y<-read_regions(con=paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Analyses/fdr5_caQTL_peak_genomeAnnotations/fdr5Peaks_metadata.forGenomeAnnotations.bed"),genome='hg38')


annots = c("hg38_genes_1to5kb","hg38_genes_promoters","hg38_genes_cds","hg38_genes_5UTRs","hg38_genes_exons","hg38_genes_firstexons","hg38_genes_introns","hg38_genes_intronexonboundaries","hg38_genes_3UTRs","hg38_genes_intergenic","hg38_enhancers_fantom","hg38_basicgenes")

# Build the annotations (a single GRanges object)
annotations = build_annotations(genome = 'hg38', annotations = annots)

# Intersect the regions we read in with the annotations
y_annotated = annotate_regions(
  regions = y,
  annotations = annotations,
  ignore.strand = TRUE,
  quiet = FALSE,minoverlap =100)

# A GRanges object is returned
#print(y_annotated)



df_dm_annotated = data.frame(y_annotated)

dm_annsum = summarize_annotations(
  annotated_regions = y_annotated,
  quiet = TRUE)
write.table(dm_annsum,"/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Analyses/fdr5_caQTL_peak_genomeAnnotations/tensorqtl_yuanAllSamples_3.10.24_prinComp200_peakAnnotations.txt")


dm_annotated<-read.table("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Analyses/fdr5_caQTL_peak_genomeAnnotations/tensorqtl_yuanAllSamples_3.10.24_prinComp200_peakAnnotations.txt")

annots_order = c("hg38_genes_1to5kb","hg38_genes_promoters","hg38_genes_cds","hg38_genes_5UTRs","hg38_genes_exons","hg38_genes_firstexons","hg38_genes_introns","hg38_genes_intronexonboundaries","hg38_genes_3UTRs","hg38_genes_intergenic","hg38_enhancers_fantom","hg38_basicgenes")

randomDF<-data.frame(dm_annotated$annot.type)
for (x in (1:1000)){
  # Randomize the input regions
  dm_random_regions = randomize_regions(regions = y,allow.overlaps = TRUE,per.chromosome = TRUE)
  
  # Annotate the random regions using the same annotations as above
  # These will be used in later functions
  dm_random_annotated = annotate_regions(regions = dm_random_regions,annotations = annotations,ignore.strand = TRUE,quiet = TRUE,minoverlap =100)
  
  df_dm_random_annotated = data.frame(dm_random_annotated)
  
  dm_annsum_random = summarize_annotations(annotated_regions = dm_random_annotated,quiet = TRUE)
  
  dm_annsum_random<-as.data.frame(dm_annsum_random)
  
  randomDF<-merge(randomDF,dm_annsum_random,by.x='dm_annotated.annot.type',by.y='annot.type',all=T)
  
}  


finalDF<-merge(randomDF,dm_annotated,by.x="dm_annotated.annot.type",by.y="annot.type",all=T)
colnames(finalDF)<-c("Annotation",paste0("Random_",rep(1:1000)),"ATAC_Peak_Regions")

#get number of shuffled values greater than real values
for (q in 1:nrow(finalDF)){
  
  pValCount <- sum(colSums(finalDF[q,2:1001] >= finalDF[q,1002]))
  
  if (pValCount == 0){
    finalDF$pval[q] <- 1/1001
  }else{
    finalDF$pval[q] <- pValCount/1000
  }
  
}


finalDF<-as.data.frame(finalDF)
finalDF[is.na(finalDF)] <- 0
finalDF$RandomMedian <- apply(finalDF[,2:1001],1,median)

write.table(finalDF,"/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Analyses/fdr5_caQTL_peak_genomeAnnotations/tensorqtl_yuanAllSamples_3.10.24_prinComp200_peakAnnotations.realRegions_vs_random_1000iterations.txt",col.names=T,row.names=F,quote=F,sep='\t')

finalDF_mod <- data.frame(finalDF$annot.type,finalDF$Random_Median,finalDF$TrueCounts)
colnames(finalDF_mod) <- c("Annotation","Random Region","caQTL_Peak")
finalDF <- finalDF_mod

write.table(finalDF,"/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Analyses/fdr5_caQTL_peak_genomeAnnotations/tensorqtl_yuanAllSamples_3.10.24_prinComp200_peakAnnotations.realRegions_vs_random_1000iterations.stats.txt",col.names=T,row.names=F,quote=F,sep='\t')

library(reshape)

dfForPlot<-melt(finalDF, id=c("Annotation"))
dfForPlot<-as.data.frame(dfForPlot)
colnames(dfForPlot)<-c("Annotation","Set","RegionCount")
dfForPlot$RegionCount<-as.character(dfForPlot$RegionCount)
dfForPlot$RegionCount<-as.numeric(dfForPlot$RegionCount)

library(ggplot2)

p=ggplot(dfForPlot,aes(x=Annotation,y=RegionCount,fill=Set)) +  geom_bar(stat="identity",position="dodge") + ylab("count")+ theme_bw()+ theme(plot.title = element_text( size=15, face="bold.italic"),axis.title.y = element_text( size=10, face="bold"), axis.text.x = element_text(face="bold", size=8),axis.text.y = element_text(face="bold", size=8)) + theme(axis.text.x = element_text(angle = 45, hjust=1)) + theme(legend.title = element_text(size = 8),legend.text = element_text(size = 8))+theme(plot.margin = margin(1,1,1.5,1.2, "cm"))

ggsave("tensorqtl_yuanAllSamples_10.14.24_prinComp200_peakAnnotations_GenomeAnnotations_vsRandom.10.15.24.png",p,width=5,height=5,dpi=1200)



#######################################################################
#####Supplementary Figure 11 - External dataset hQTL replication#######
#######################################################################

library(data.table)
library(ggplot2)
library(dplyr)

#read in multiTissue caQTLs
lead_caqtls <- read.table("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/tensorQTL/10.9.24_analyses/tensorQTL_results/tensorqtl_yuanAllSamples_10.9.24_prinComp200_allChr.cis_qtl.fdr5.txt",header=T)

#read in enhancer hQTLs
hqtls <- fread("enhancer_hQTLs.txt")

#get overlap of lead caqtl variants with lead hqtls
length(unique(intersect(lead_caqtls$variant_id,hqtls$"epiQTL rsID")))
#137

allBackgroundOverlaps<-data.frame()
#read in background data
for (i in (1:100)){
  background <- fread(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Analyses/multiTissueReplication_Analyses/eQTL_caQTL_enrichment/eqtl_caqtl_overlap_background_variants/backgroundVars_caQTL_matched_closestGene_AF_for_eQTL_subsetFromAll.overlap.wiggleMethod.parallel.iteration.",i,".10.15.24.txt"),header=T)
  
  #get overlap of background variants with lead hqtls
  backgroundLength <- length(unique(intersect(background$varID,hqtls$"epiQTL rsID")))
  allBackgroundOverlaps <- rbind(allBackgroundOverlaps,backgroundLength)
}

#add column names
colnames(allBackgroundOverlaps) <- c("Overlaps")

#median
median(allBackgroundOverlaps$Overlaps)
#23


#check effect size correlation
mergedDF <- merge(lead_caqtls,hqtls,by.x="variant_id",by.y="epiQTL rsID")
colnames(mergedDF) <- gsub(" ","_",colnames(mergedDF))
mergedDF$hqtl_slope <- mergedDF$"log2_(effect_size)"

#get ref allele info
allChrom_ref <- data.frame()
for (chrom in 1:22){
  
  multiTissueAF = fread(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/tensorQTL/genotype/chr",chrom,".allFinalSamples.AF_filesForColocFinal.txt"),header=T)
  multiTissueAF <- as.data.frame(multiTissueAF)
  multiTissueAF = within(multiTissueAF, INFO<-data.frame(do.call('rbind', strsplit(as.character(INFO), '=', fixed=TRUE))))
  AF=as.character(multiTissueAF$INFO$X4)
  multiTissueAF$MAF = as.numeric(AF)
  allChrom_ref <- rbind(allChrom_ref,multiTissueAF)
}

#add ref allele info
mergedDF_final <- merge(mergedDF,allChrom_ref,by.x="variant_id",by.y="ID")

#loop to check if reference is aligned
totalConcordant=0
for(q in 1:nrow(mergedDF_final)){
  row <- mergedDF_final[q,]
  if (row$Ref_Allelec == row$REF){
    print("True")
    totalConcordant=totalConcordant+1
  }
}

#row 28 is seemingly flipped - I am not sure how to flip it given effect size id log2()? Just remove it
mergedDF_final <- mergedDF[-28,]

#plot - flip caQTL slope since hqtl slope is reported with respect to REFERENCE ALLELE and tensorQTL reports with respect to ALT ALLELE
ggplot(mergedDF_final, aes(x=-slope, y=hqtl_slope)) + geom_point() + xlab("caQTL Effect Size") + ylab("hQTL Effect Size") + geom_smooth(method = "lm",formula = y ~ x)
ggsave("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/manuscript_review_analyses/additional_qtl_studies/leadCaqtl_matched_hQTL_effectSizeCorrelation.png")

#check all caQTL results overlap
allChr_results <- data.frame()
for (chrom in (1:22)){
  
  stats <- fread(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/tensorQTL/10.9.24_analyses/tensorQTL_results/tensorqtl_yuanAllSamples_10.9.24_prinComp200_allChr.cisNominal.cis_qtl_pairs.",chrom,".txt"))
  allChr_results <- rbind(allChr_results,stats)
  
  
}

#merge all results with hqtls
mergedDF_all <- merge(allChr_results,hqtls,by.x="variant_id",by.y="epiQTL rsID")

#add ref allele info
mergedDF_all_final <- merge(mergedDF_all,allChrom_ref,by.x="variant_id",by.y="ID")
colnames(mergedDF_all_final) <- gsub(" ","_",colnames(mergedDF_all_final))

totalConcordant=0
for(q in 1:nrow(mergedDF_all_final)){
  row <- mergedDF_all_final[q,]
  if (row$Ref_Allelec == row$REF){
    print("True")
    totalConcordant=totalConcordant+1
  }
}

totalConcordant
#[1] 66670

#remove discordant allele rows
removeRows <- which(mergedDF_all_final$Ref_Allelec != mergedDF_all_final$REF)
mergedDF_all_final_rowsRemoved <- mergedDF_all_final[-removeRows,]
mergedDF_all_final_rowsRemoved$hqtl_slope <- mergedDF_all_final_rowsRemoved$"log2_(effect_size)"

#get pi1 replication
pi1 = 1 - qvalue::qvalue(mergedDF_all_final_rowsRemoved$pval_nominal)$pi0
pi1
#[1] 0.268893


#plot - flip caQTL slope since hqtl slope is reported with respect to REFERENCE ALLELE and tensorQTL reports with respect to ALT ALLELE
ggplot(mergedDF_all_final_rowsRemoved, aes(x=-slope, y=hqtl_slope)) + geom_point() + xlab("caQTL Effect Size") + ylab("hQTL Effect Size") + geom_smooth(method = "lm",formula = y ~ x)
ggsave("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/manuscript_review_analyses/additional_qtl_studies/all_tests_Caqtl_matched_hQTL_effectSizeCorrelation.png")

#plot distribution of caQTL nominal pvalues - matched on hqtl lead variant
ggplot(mergedDF_all_final_rowsRemoved, aes(x=pval_nominal))+ geom_histogram(color="darkblue", fill="lightblue",bins=100) + xlab("hQTL-matched caQTL test nominal p-values") + ylab("Counts") + theme_bw() + theme(text=element_text(size=28))
ggsave("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/manuscript_review_analyses/additional_qtl_studies/hqtl_matched_caQTL_pvals.png",width=10,height=10,dpi=1000)

#get min p-value per variant
mergedDF_all_final_rowsRemoved_min <- mergedDF_all_final_rowsRemoved %>% group_by(variant_id) %>% slice(which.min(pval_nominal))

pi1 = 1 - qvalue::qvalue(mergedDF_all_final_rowsRemoved_min$pval_nominal)$pi0
pi1
#[1] 0.9956355

#plot distribution of caQTL nominal pvalues - matched on hqtl lead variant
ggplot(mergedDF_all_final_rowsRemoved_min, aes(x=pval_nominal))+ geom_histogram(color="darkblue", fill="lightblue",bins=100) + xlab("hQTL-matched caQTL test nominal p-values") + ylab("Counts") + theme_bw() + theme(text=element_text(size=28))
ggsave("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/manuscript_review_analyses/additional_qtl_studies/hqtl_matched_caQTL_min_pvals.png",width=10,height=10,dpi=1000)



#####################################################################################
#####Supplementary Figure 12 - Colocalizing caQTL/eQTL Effect Size Correlation#######
#####################################################################################

library(data.table)
library(dplyr)
library(ggplot2)

#read in eqtl/caqtl coloc results
eqtl_meta <- fread("/project/voight_ML/bwenz/Liver_caQTL_Mapping/paper_analyses_7.12.24/Results/coloc/eQTL/metaAnalyzed_eqtl_caqtl_colocalizations_fullWindow_forPaper_SupplementaryTable_altStrategy.12.11.24.txt")
eqtl_meta$dataset <- "meta"

eqtl_gtex <- fread("/project/voight_ML/bwenz/Liver_caQTL_Mapping/paper_analyses_7.12.24/Results/coloc/eQTL/gtex_eqtl_caqtl_colocalizations_fullWindow_forPaper_SupplementaryTable_altStrategy.12.11.24.txt")
eqtl_gtex$dataset <- "gtex"

x <- rbind(eqtl_meta,eqtl_gtex)

#get colocs with same lead caQTL/eQTL
sameVar <- x %>% dplyr::filter(leadcaQTLVariant==leadeQTLVariant)

#create unique column for merging
sameVar$unique <- paste0(sameVar$eGene,"_",sameVar$leadeQTLVariant)

#read in caQTL results
lead_caqtls <- read.table("/project/voight_ML/bwenz/Liver_caQTL_Mapping/rasqual/caQTL_175_samples_newVersion_3.6.24/rasqual_liver_175samples_fdr5_caqtls_4.1.24.txt",header=T)

#read in gtex to get effect sizes
eqtl <- fread("/project/voight_datasets_01/GTEx_v8/TissueSpecific/Liver.allpairs.txt.gz")
eqtl$unique <- paste0(eqtl$gene_id,"_",eqtl$variant_id)

#split into gtex and meta
#gtex
sameVar_gtex <- sameVar %>% dplyr::filter(dataset=="gtex")

#merge eqtl and sameVar df to get effect size
sameVar_gtex_eqtl_merged <- merge(sameVar_gtex,eqtl,by="unique")

#merge sameVar with eqtl info with lead caqtl info
sameVar_eqtl_merged_caqtl <- merge(sameVar_gtex_eqtl_merged,lead_caqtls,by.x="feature",by.y="Feature_ID")

#get subset to bind gtex and meta
sameVar_eqtl_merged_caqtl_sub <- data.frame(sameVar_eqtl_merged_caqtl$rs_ID,sameVar_eqtl_merged_caqtl$slope,sameVar_eqtl_merged_caqtl$Effect_Size)
colnames(sameVar_eqtl_merged_caqtl_sub) <- c("rs_ID","Slope","Effect_Size")

#meta
allMeta_chrs <- data.frame()

for (chrom in 1:22){ 
  meta_chr <- fread(paste0("/project/voight_ML/bwenz/Liver_caQTL_Mapping/paper_analyses_7.12.24/Data/chr",chrom,"_marginal_summary_results.hg38.tsv"),header=T)
  allMeta_chrs <- rbind(allMeta_chrs,meta_chr)
}

#create variant_id column
allMeta_chrs$Variant_id <- paste0(allMeta_chrs$CHR,":",allMeta_chrs$start)

allMeta_chrs$unique <- paste0(allMeta_chrs$GeneSymbol,"_",allMeta_chrs$Variant_id)

sameVar_meta <- sameVar %>% dplyr::filter(dataset=="meta")

#merge eqtl and sameVar df to get effect size
sameVar_meta_eqtl_merged <- merge(sameVar_meta,allMeta_chrs,by="unique")

#merge sameVar with eqtl info with lead caqtl info
sameVar_meta_eqtl_merged_caqtl <- merge(sameVar_meta_eqtl_merged,lead_caqtls,by.x="feature",by.y="Feature_ID")

#get subset of sameVar_meta_eqtl_merged_caqtl
sameVar_meta_eqtl_merged_caqtl_sub <- data.frame(sameVar_meta_eqtl_merged_caqtl$rs_ID,sameVar_meta_eqtl_merged_caqtl$Beta,sameVar_meta_eqtl_merged_caqtl$Effect_Size)
colnames(sameVar_meta_eqtl_merged_caqtl_sub) <- c("rs_ID","Slope","Effect_Size")

#bind both subsets
subsetsFinal <- rbind(sameVar_eqtl_merged_caqtl_sub,sameVar_meta_eqtl_merged_caqtl_sub)

#plot scatter plot of effect sizes for eqtl/caqtl
ggplot(subsetsFinal, aes(x=Slope, y=Effect_Size-0.5)) + geom_point() + geom_smooth(method=lm) + xlab("eQTL Slope") + ylab("RASQUAL caQTL Effect Size")
ggsave('/project/voight_ML/bwenz/Liver_caQTL_Mapping/paper_analyses_7.12.24/Results/coloc/eQTL/colocalizing_eqtl_caqtl_sameLeadVar_effectSizes.1.2.25.png',height=6,width=6,unit='in')





#######################################################################
#####Supplementary Figure 13 - caQTL/eQTL colocalization statistics#####
#######################################################################

#####
##A##
#####

library(data.table)
library(dplyr)
library(readr)
library(ggplot2)



#read in tissue file
tissueList <- fread("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Analyses/multiTissueReplication_Analyses/eQTL_caQTL_enrichment/tissueFileList.txt")

#grab only file name column
tissueList <- tissueList$V9

#remove file suffix
tissueList <- gsub(".v8.egenes.txt.gz","",tissueList)

allTissueDF<-data.frame()
allTissue_uniquePerTissue <- data.frame()
for (tissue in tissueList){
  colocs <- fread(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/caqtl_eqtl_coloc/newGTF/colocs_10_15_24/multiTissue_fdr5_Peaks_",tissue,"_allchr_eQTL_coloc.filtered.10.15.24.txt"))
  allTissueDF <- rbind(allTissueDF,colocs)
  
  tissue_unique <- data.frame(tissue,unique(colocs$eGene))
  allTissue_uniquePerTissue <- rbind(allTissue_uniquePerTissue,tissue_unique)
}

#final gene per tissue counts
tissue_geneCounts <- as.data.frame(table(allTissue_uniquePerTissue$unique.colocs.eGene.))

#write unique genes per tissue to file
write.table(allTissue_uniquePerTissue,"/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/caqtl_eqtl_coloc/allTissues_unique_colocalizing_egenes.10.21.24.txt",col.names=T,row.names = F,quote=F,sep='\t')

#check median value
median(tissue_geneCounts$Freq)
#[1] 3

mean(tissue_geneCounts$Freq)
#[1] 7.735734

#plot number of egenes found across number of tissues
ggplot(tissue_geneCounts, aes(x=Freq))+ geom_histogram(color="darkblue", fill="lightblue",bins=49) + xlab("Number of Tissues in Which Gene \n Colocalizes with caQTL") + theme(text=element_text(size=24))
ggsave("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/caqtl_eqtl_coloc/numberOfTissues_per_caqtl_eatl_coloc.10.21.24.png",height=8,width=10,units = "in")

#####
##B##
#####

library(dplyr)
library(tidyr)
library(readr)
library(reshape)
library(data.table)
library(coloc)
library(qvalue)
library(GenomicRanges)
library(R.utils)
library(jjb)
library(stringr)
library(TwoSampleMR)
library(ieugwasr)
library(arrow)
library(splitstackshape)
library(ggplot2)


#read in coloc stats
colocStats <- fread("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/caqtl_eqtl_coloc/newGTF/colocs_10_15_24/bulk_caqtl_eqtl_colocs_nearestGeneStats.10.18.24.txt")
colocStats <- as.data.frame(colocStats)

median(colocStats$tss_caQTL_dist)
#[1] 214
median(abs(colocStats$tss_caQTL_dist))
#[1] 76129


#get number of closest genes
colocStats_sameGene <- colocStats %>% dplyr::filter(eGene==closestgene)

#get proportion of colocs that are same gene
sameGeneNum <- nrow(colocStats_sameGene)
allColocNum <- nrow(colocStats)

proportion <- (sameGeneNum/allColocNum)*100
#[1] 14.25

#plot number of genes closer than colocalizing gene
ggplot(colocStats, aes(x=closerCount))+ geom_histogram(color="darkblue", fill="lightblue",bins=100) + xlab("Number of Genes Closer to caQTL \n than Colocalizing Gene") + ylab("Counts") + theme(text=element_text(size=24))
ggsave("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/caqtl_eqtl_coloc/numGenes_closer_to_caqtl_than_colocGene.10.21.24.png",height=8,width=10,units = "in")

#####
##C##
#####

library(dplyr)
library(tidyr)
library(readr)
library(reshape)
library(data.table)
library(coloc)
library(qvalue)
library(GenomicRanges)
library(R.utils)
library(jjb)
library(stringr)
library(TwoSampleMR)
library(ieugwasr)
library(arrow)
library(splitstackshape)
library(ggplot2)



#read in data
bulk_eqtl_caqtl <- fread("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/caqtl_eqtl_coloc/newGTF/colocs_10_15_24/bulk_caqtl_eqtl_colocs_nearestGeneStats.10.18.24.txt")


#plot distance between caqtl and lead eqtl
ggplot(bulk_eqtl_caqtl, aes(x=tss_caQTL_dist))+ geom_histogram(color="darkblue", fill="lightblue",bins=100) + xlab("Distance Between Lead caQTL and \n Colocalizing eGene TSS") + ylab("Counts") + theme(text=element_text(size=24))
ggsave("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/caqtl_eqtl_coloc/distance_between_lead_caqtl_and_colocalizing_egene_tss.10.21.24.png",height=8,width=10)





#####################################################################################
#####Supplementary Figure 14 - Number of QTL Colocalizations per GWAS Lead Signal#####
#####################################################################################

library(data.table)
library(dplyr)
library(tidyverse)
library(splitstackshape)

clump_par = 0.01

key = read.table("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/phenoKey.txt")

tissueList <- fread("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/eqtl_gwas_coloc/eQTL_GWAS_coloc/gtexTissueList.txt",header=F)

key = read.table("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/phenoKey.txt")
key$V2 <- gsub("Neutrophill","Neutrophil",key$V2)
key$V2 <- gsub("Eosinophill","Eosinophil",key$V2)

gwasLeads <- fread("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/chosenTraits_bw/allLeadGwas.txt")
gwasLeads <- cSplit(gwasLeads,"V2",sep="/")

allTissueDF <- data.frame() 
all_caqtl_colocs <- data.frame()
allPhenoTissue <- data.frame()
for (pheno in key$V1){
  
  phenoInfo=key %>% filter(V1==pheno)
  print(phenoInfo)
  keyTrait = as.character(phenoInfo$V2)
  print(keyTrait)
  
  leadDF <- gwasLeads %>% dplyr::filter(V2_1==pheno)
  lead_gwas_num <- leadDF$V1
  
  for (tissue in tissueList$V1){
    
    
    #create df for combined results
    combined_df <- data.frame()
    #read in file
    #new results
    
    if (file.exists(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/caqtl_eqtl_coloc/newGTF/eQTL_GWAS/",pheno,"_",tissue,"_all_chr.eQTL_coloc.pruned.",clump_par,".newGTF.8.21.24.txt"))){
      if (file.exists(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/caqtl_eqtl_coloc/newGTF/eQTL_GWAS/",pheno,"_",tissue,"_all_chr.eQTL_coloc.pruned.",clump_par,".newGTF.8.21.24.filtered.txt"))){
        if (file.info(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/caqtl_eqtl_coloc/newGTF/eQTL_GWAS/",pheno,"_",tissue,"_all_chr.eQTL_coloc.pruned.",clump_par,".newGTF.8.21.24.filtered.txt"))$size > 1){
          colocFinal <- fread(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/caqtl_eqtl_coloc/newGTF/eQTL_GWAS/",pheno,"_",tissue,"_all_chr.eQTL_coloc.pruned.",clump_par,".newGTF.8.21.24.filtered.txt"),header=T)
          allTissueDF <- rbind(allTissueDF,colocFinal)
        }else{
          print("no colocs")
        }
        
      }else{
        x <- fread(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/caqtl_eqtl_coloc/newGTF/eQTL_GWAS/",pheno,"_",tissue,"_all_chr.eQTL_coloc.pruned.",clump_par,".newGTF.8.21.24.txt"))
        if (nrow(x) > 1 ){
          x <- na.omit(x)
          
          numPassPower=0
          
          
          colocNum=nrow(x)
          x$power<-x$pp3 + x$pp4
          colocFinal<-data.frame()
          for (row in 1:nrow(x)) {
            if (x$power[row] > 0.8) {
              numPassPower=numPassPower+1
              coloc = ((x$pp4[row])/(x$pp4[row]+x$pp3[row]))
              if (coloc > 0.9) {
                if (x$numsnp[row]>15){
                  colocLine = cbind(x[row],coloc)
                  colocLine = data.frame(colocLine)
                  colocFinal = rbind(colocFinal,colocLine)
                }
              }
            }
          }
          print(head(colocFinal))
          print(dim(colocFinal))
          
          #read in old results
          
          
          allTissueDF <- rbind(allTissueDF,colocFinal)        
          
          #combine results to combined df
          combined_df <- rbind(combined_df,colocFinal)
          
          write.table(colocFinal,paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/caqtl_eqtl_coloc/newGTF/eQTL_GWAS/",pheno,"_",tissue,"_all_chr.eQTL_coloc.pruned.",clump_par,".newGTF.8.21.24.filtered.txt"),sep="\t",row.names = FALSE, col.names = TRUE, quote = F)
        }     
      }
    }
    
    
    #old results
    if (file.exists(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/eqtl_gwas_coloc/eQTL_GWAS_coloc/",pheno,"_colocResults/",pheno,"_",tissue,"_all_chr.eQTL_coloc.pruned.",clump_par,".4.24.24.txt"))){
      if (file.exists(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/eqtl_gwas_coloc/eQTL_GWAS_coloc/",pheno,"_colocResults/",pheno,"_",tissue,"_all_chr.eQTL_coloc.pruned.",clump_par,".4.24.24.filtered.txt"))){
        if (file.info(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/eqtl_gwas_coloc/eQTL_GWAS_coloc/",pheno,"_colocResults/",pheno,"_",tissue,"_all_chr.eQTL_coloc.pruned.",clump_par,".4.24.24.filtered.txt"))$size > 1){
          colocFinal <- fread(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/eqtl_gwas_coloc/eQTL_GWAS_coloc/",pheno,"_colocResults/",pheno,"_",tissue,"_all_chr.eQTL_coloc.pruned.",clump_par,".4.24.24.filtered.txt"),header=T)
          allTissueDF <- rbind(allTissueDF,colocFinal)
        }else{
          print("no colocs")
        }
        
      }else{
        x <- fread(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/eqtl_gwas_coloc/eQTL_GWAS_coloc/",pheno,"_colocResults/",pheno,"_",tissue,"_all_chr.eQTL_coloc.pruned.",clump_par,".4.24.24.txt"))
        if (nrow(x) > 1 ){
          x <- na.omit(x)
          
          numPassPower=0
          
          
          colocNum=nrow(x)
          x$power<-x$pp3 + x$pp4
          colocFinal<-data.frame()
          for (row in 1:nrow(x)) {
            if (x$power[row] > 0.8) {
              numPassPower=numPassPower+1
              coloc = ((x$pp4[row])/(x$pp4[row]+x$pp3[row]))
              if (coloc > 0.9) {
                if (x$numsnp[row]>15){
                  colocLine = cbind(x[row],coloc)
                  colocLine = data.frame(colocLine)
                  colocFinal = rbind(colocFinal,colocLine)
                }
              }
            }
          }
          print(head(colocFinal))
          print(dim(colocFinal))
          
          allTissueDF <- rbind(allTissueDF,colocFinal)        
          
          #add data to combined df
          combined_df <- rbind(combined_df,colocFinal)
          
          write.table(colocFinal,paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/eqtl_gwas_coloc/eQTL_GWAS_coloc/",pheno,"_colocResults/",pheno,"_",tissue,"_all_chr.eQTL_coloc.pruned.",clump_par,".4.24.24.filtered.txt"),sep="\t",row.names = FALSE, col.names = TRUE, quote = F)
        }     
      }
    }
    
    
    
    
    
    
  }
  
  
  
  if (file.exists(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/chosenTraits_bw/",pheno,"_colocResults/",keyTrait,"_",pheno,"_multiTissue_allPeaks_coloc.pruned.",clump_par,"_allColocResults.Final.filtered.withStats.10.19.24.txt"))){
    
    caQTL_colocs <- fread(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/chosenTraits_bw/",pheno,"_colocResults/",keyTrait,"_",pheno,"_multiTissue_allPeaks_coloc.pruned.",clump_par,"_allColocResults.Final.filtered.withStats.10.19.24.txt"))
    all_caqtl_colocs <- rbind(all_caqtl_colocs,caQTL_colocs)
  }
  
}

#write all caqtl/gwas colocs to table
write.table(all_caqtl_colocs,"/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/chosenTraits_bw/allTraits_all_caqtl_gwas_colocs_passFilter.10.19.24.txt",col.names=T,row.names = F,quote=F,sep='\t')

#caqtl/gwas

#get medians
median(table(all_caqtl_colocs$gwas_lead))
#[1] 2

#plot counts
all_caqtl_colocs_counts <- data.frame(table(all_caqtl_colocs$gwas_lead))
all_caqtl_colocs_counts$type <- "caqtl"

#eqtl/gwas

#get medians
median(table(allTissueDF$leadGwasVariant))
#[1] 6

#plot counts
all_eqtl_colocs_counts <- data.frame(table(allTissueDF$leadGwasVariant))
all_eqtl_colocs_counts$type <- "eqtl"


#add to same df
allRuns_df <- rbind(all_caqtl_colocs_counts,all_eqtl_colocs_counts)
allRuns_df$type <- gsub("eqtl","eQTL",allRuns_df$type )
allRuns_df$type <- gsub("caqtl","caQTL",allRuns_df$type )

#create medians df
medians <- data.frame()
eqtl_median <- median(all_eqtl_colocs_counts$Freq)
eqtl_median_df <- data.frame("eqtl",eqtl_median)
medians <- rbind(medians,eqtl_median_df)
colnames(medians) <- c("type","median")

caqtl_median <- median(all_caqtl_colocs_counts$Freq)
caqtl_median_df <- data.frame("caqtl",caqtl_median)
colnames(caqtl_median_df) <- c("type","median")
medians <- rbind(medians,caqtl_median_df)

medians$median <- log10(medians$median)

#plot
p <- ggplot(allRuns_df, aes(x=type, y=log10(Freq),fill=type)) + geom_boxplot() + theme(legend.position="right")
p <- p + guides(fill=guide_legend(title="Colocalizing QTL Type")) +  ggtitle("Number of QTL Colocalizations per GWAS Lead Signal") + ylab("log10(Number of QTL Colocalizations Involving GWAS Signal)") + xlab("QTL Type")
ggsave("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/chosenTraits_bw/gwas_variants_num_caqtl_eqtl_colocalize_with_forPaper.10.21.24.png",p,height=8,width=8,dpi=1000)


#####################################################################################
#####Supplementary Figure 15 - caQTL Only Colocalization Posterior Probabilities#####
#####################################################################################

#R
library(data.table)
library(dplyr)
library(tidyverse)
library(splitstackshape)
library(ggplot2)

clump_par = 0.01

key = read.table("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/phenoKey.txt")

tissueList <- fread("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/caqtl_eqtl_coloc/newGTF/gtexTissueList.txt",header=F)

key = read.table("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/phenoKey.txt")
key$V2 <- gsub("Neutrophill","Neutrophil",key$V2)
key$V2 <- gsub("Eosinophill","Eosinophil",key$V2)

gwasLeads <- fread("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/chosenTraits_bw/allLeadGwas.txt")
gwasLeads <- cSplit(gwasLeads,"V2",sep="/")

#read in geneids
#gene coordinates
geneids = read_delim("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/gencode.v24.gencodeidsandcoordinates.txt",comment="#",delim="\t",col_names=FALSE)

#get only missing gene ids
geneids_2 = fread("/project/voight_ML/bwenz/Liver_caQTL_Mapping/InputData/gencode.v26.GRCh38.genes.brandonEdits.txt")

allgene_ids <- merge(geneids,geneids_2)

all_caQTL_only_df <- data.frame()
allPhenoTissue <- data.frame()
for (pheno in key$V1){
  
  phenoInfo=key %>% dplyr::filter(V1==pheno)
  print(phenoInfo)
  keyTrait = as.character(phenoInfo$V2)
  print(keyTrait)
  
  leadDF <- gwasLeads %>% dplyr::filter(V2_1==pheno)
  lead_gwas_num <- leadDF$V1
  
  allTissueDF <- data.frame() 
  for (tissue in tissueList$V1){
    
    #create df for combined results
    combined_df <- data.frame()
    #read in file
    #new results
    
    if (file.exists(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/caqtl_eqtl_coloc/newGTF/eQTL_GWAS/",pheno,"_",tissue,"_all_chr.eQTL_coloc.pruned.",clump_par,".newGTF.8.21.24.txt"))){
      if (file.exists(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/caqtl_eqtl_coloc/newGTF/eQTL_GWAS/",pheno,"_",tissue,"_all_chr.eQTL_coloc.pruned.",clump_par,".newGTF.8.21.24.filtered.txt"))){
        if (file.info(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/caqtl_eqtl_coloc/newGTF/eQTL_GWAS/",pheno,"_",tissue,"_all_chr.eQTL_coloc.pruned.",clump_par,".newGTF.8.21.24.filtered.txt"))$size > 1){
          colocFinal <- fread(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/caqtl_eqtl_coloc/newGTF/eQTL_GWAS/",pheno,"_",tissue,"_all_chr.eQTL_coloc.pruned.",clump_par,".newGTF.8.21.24.filtered.txt"),header=T)
          allTissueDF <- rbind(allTissueDF,colocFinal)
        }else{
          print("no colocs")
        }
        
      }else{
        x <- fread(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/caqtl_eqtl_coloc/newGTF/eQTL_GWAS/",pheno,"_",tissue,"_all_chr.eQTL_coloc.pruned.",clump_par,".newGTF.8.21.24.txt"))
        if (nrow(x) > 1 ){
          x <- na.omit(x)
          
          numPassPower=0
          
          
          colocNum=nrow(x)
          x$power<-x$pp3 + x$pp4
          colocFinal<-data.frame()
          for (row in 1:nrow(x)) {
            if (x$power[row] > 0.8) {
              numPassPower=numPassPower+1
              coloc = ((x$pp4[row])/(x$pp4[row]+x$pp3[row]))
              if (coloc > 0.9) {
                if (x$numsnp[row]>15){
                  colocLine = cbind(x[row],coloc)
                  colocLine = data.frame(colocLine)
                  colocFinal = rbind(colocFinal,colocLine)
                }
              }
            }
          }
          print(head(colocFinal))
          print(dim(colocFinal))
          
          #read in old results
          
          
          allTissueDF <- rbind(allTissueDF,colocFinal)        
          
          #combine results to combined df
          combined_df <- rbind(combined_df,colocFinal)
          
          write.table(colocFinal,paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/caqtl_eqtl_coloc/newGTF/eQTL_GWAS/",pheno,"_",tissue,"_all_chr.eQTL_coloc.pruned.",clump_par,".newGTF.8.21.24.filtered.txt"),sep="\t",row.names = FALSE, col.names = TRUE, quote = F)
        }     
      }
    }
    
    #old results
    if (file.exists(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/eqtl_gwas_coloc/eQTL_GWAS_coloc/",pheno,"_colocResults/",pheno,"_",tissue,"_all_chr.eQTL_coloc.pruned.",clump_par,".4.24.24.txt"))){
      if (file.exists(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/eqtl_gwas_coloc/eQTL_GWAS_coloc/",pheno,"_colocResults/",pheno,"_",tissue,"_all_chr.eQTL_coloc.pruned.",clump_par,".4.24.24.filtered.txt"))){
        if (file.info(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/eqtl_gwas_coloc/eQTL_GWAS_coloc/",pheno,"_colocResults/",pheno,"_",tissue,"_all_chr.eQTL_coloc.pruned.",clump_par,".4.24.24.filtered.txt"))$size > 1){
          colocFinal <- fread(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/eqtl_gwas_coloc/eQTL_GWAS_coloc/",pheno,"_colocResults/",pheno,"_",tissue,"_all_chr.eQTL_coloc.pruned.",clump_par,".4.24.24.filtered.txt"),header=T)
          allTissueDF <- rbind(allTissueDF,colocFinal)
        }else{
          print("no colocs")
        }
        
      }else{
        x <- fread(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/eqtl_gwas_coloc/eQTL_GWAS_coloc/",pheno,"_colocResults/",pheno,"_",tissue,"_all_chr.eQTL_coloc.pruned.",clump_par,".4.24.24.txt"))
        if (nrow(x) > 1 ){
          x <- na.omit(x)
          
          numPassPower=0
          
          
          colocNum=nrow(x)
          x$power<-x$pp3 + x$pp4
          colocFinal<-data.frame()
          for (row in 1:nrow(x)) {
            if (x$power[row] > 0.8) {
              numPassPower=numPassPower+1
              coloc = ((x$pp4[row])/(x$pp4[row]+x$pp3[row]))
              if (coloc > 0.9) {
                if (x$numsnp[row]>15){
                  colocLine = cbind(x[row],coloc)
                  colocLine = data.frame(colocLine)
                  colocFinal = rbind(colocFinal,colocLine)
                }
              }
            }
          }
          print(head(colocFinal))
          print(dim(colocFinal))
          
          allTissueDF <- rbind(allTissueDF,colocFinal)        
          
          #add data to combined df
          combined_df <- rbind(combined_df,colocFinal)
          
          write.table(colocFinal,paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/eqtl_gwas_coloc/eQTL_GWAS_coloc/",pheno,"_colocResults/",pheno,"_",tissue,"_all_chr.eQTL_coloc.pruned.",clump_par,".4.24.24.filtered.txt"),sep="\t",row.names = FALSE, col.names = TRUE, quote = F)
        }     
      }
    }
    
    #write combined file 
    write.table(combined_df,paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/caqtl_eqtl_coloc/newGTF/eQTL_GWAS/",pheno,"_",tissue,"_all_chr.eQTL_coloc.pruned.",clump_par,".newGTF.8.21.24.old_new.filtered.txt"),row.names=F,col.names=T,quote=F,sep='\t')
    
    
    #remove chr from lead gwas
    allTissueDF$leadGwasVariant <- gsub("chr","",allTissueDF$leadGwasVariant)
    
    
    #read in caqtl-gwas
    if (file.exists(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/chosenTraits_bw/",pheno,"_colocResults/",keyTrait,"_",pheno,"_multiTissue_allPeaks_coloc.pruned.",clump_par,"_allColocResults.Final.filtered.withStats.10.19.24.txt"))){
      
      caQTL_colocs <- fread(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/chosenTraits_bw/",pheno,"_colocResults/",keyTrait,"_",pheno,"_multiTissue_allPeaks_coloc.pruned.",clump_par,"_allColocResults.Final.filtered.withStats.10.19.24.txt"))
      
      
      #get overlap
      overlap <- intersect(caQTL_colocs$gwas_lead,allTissueDF$leadGwasVariant)
      
      #get caqtl and eqtl specific lead gwas variant colocs
      caqtl_specific <- setdiff(caQTL_colocs$gwas_lead,allTissueDF$leadGwasVariant)
      eqtl_specific <- setdiff(allTissueDF$leadGwasVariant,caQTL_colocs$gwas_lead)
      
      #get data frame for caQTL only gwas colocalization
      caQTL_only_df <- caQTL_colocs %>% dplyr::filter(gwas_lead %in% caqtl_specific)
      all_caQTL_only_df <- rbind(all_caQTL_only_df,caQTL_only_df)
      
      
      clusterDF <- data.frame(keyTrait,length(overlap),length(caqtl_specific),nrow(caQTL_colocs),length(eqtl_specific),nrow(allTissueDF),lead_gwas_num)
      colnames(clusterDF) <- c("Pheno","Lead GWAS Variants Colocalize with caQTL and eQTL","Lead GWAS Variants Colocalize with caQTL Only","Total Number of caQTL/GWAS Colocalizations","Lead GWAS Variants Colocalize with eQTL Only","Total Number of eQTL/GWAS Colocalizations","Independent Lead GWAS Signals Tested")
      
      clusterDF <- na.omit(clusterDF)
    }
  }
  allPhenoTissue <- rbind(allPhenoTissue,clusterDF)
  print("tissues")
  print(length(unique(allTissueDF$Tissue)))
}


#caqtl only results are in all_caQTL_only_df
#get unique
all_caQTL_only_df <- unique(all_caQTL_only_df)

#add unique column to match on
all_caQTL_only_df$uniq <- paste0(all_caQTL_only_df$gwas_trait,"_",all_caQTL_only_df$gwas_lead)

#read in all eqtl coloc run stats so that we can check for same lead gwas variant
eqtlStats <- fread("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/manuscript_review_analyses/all_eqtl_coloc_run_results.txt")

#add coloc stats
eqtlStats$power <- eqtlStats$pp3+eqtlStats$pp4
eqtlStats$coloc <- eqtlStats$pp4/eqtlStats$power

#filter out eqtls that coloc
eqtlStats_noColoc <- eqtlStats %>% dplyr::filter(coloc < 0.9)

#add unique column to match on
eqtlStats_noColoc$uniq <- paste0(eqtlStats_noColoc$Trait,"_",eqtlStats_noColoc$leadGwasVariant)

#merge to add eqtl info
mergedForPlot <- merge(eqtlStats_noColoc,all_caQTL_only_df,by="uniq",allow.cartesian=TRUE)
mergedForPlot_final <- merge(mergedForPlot,geneids_2,by.x="eGene",by.y="V6")

#get plot subset
plottingSubset <- data.frame(mergedForPlot_final$pp1.x,mergedForPlot_final$pp2.x,mergedForPlot_final$pp3.x,mergedForPlot_final$pp4.x)

#pivot longer
plottingSubset_long <- pivot_longer(plottingSubset, cols = 1:4)

plottingSubset_long$name <- gsub("mergedForPlot_final.","",plottingSubset_long$name)
plottingSubset_long$name <- gsub(".x","",plottingSubset_long$name)

#plot
ggplot(plottingSubset_long, aes(name, value, fill = name)) + geom_boxplot() + labs(y = "Distribution", x = "COLOC Posterior Probabilities of eQTL/GWAS Colocalization") + ggtitle("GWAS Signals Colocalized with caQTLs Only Compared to eQTLs")+ theme(text = element_text(size = 18))
ggsave("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/manuscript_review_analyses/all_caQTL_coloc_only_eQTL_coloc_posterior_probs.png",height=10,width=12,units="in")





#####################################################################
#####Supplementary Figure 16 - caQTL Only Colocalization Example#####
#####################################################################

##modify function
gg_genetracks <- function(loc,
                          filter_gene_name = NULL,
                          filter_gene_biotype = NULL,
                          border = FALSE,
                          cex.axis = 1,
                          cex.lab = 1,
                          cex.text = 0.7,
                          gene_col = ifelse(showExons, 'blue4', 'skyblue'),
                          exon_col = 'blue4',
                          exon_border = 'blue4',
                          showExons = TRUE,
                          maxrows = NULL,
                          text_pos = 'top',
                          xticks = TRUE,
                          xlab = NULL) {
  if (!inherits(loc, "locus")) stop("Object of class 'locus' required")
  g <- genetracks_grob(loc,
                       filter_gene_name,
                       filter_gene_biotype,
                       border,
                       cex.text,
                       gene_col,
                       exon_col,
                       exon_border,
                       showExons,
                       maxrows,
                       text_pos)
  if (is.null(xlab) & xticks) xlab <- paste("Chromosome", loc$seqname, "(Mb)")
  
  g2 <- ggplot(data.frame(x = NA),
               aes(xmin = loc$xrange[1] / 1e6, xmax = loc$xrange[2] / 1e6)) + 
    geom_vline(xintercept = peakMetadata_filt$Start/1e6, linetype="dotted", color = "orange", size=1.5) + 
    geom_vline(xintercept = peakMetadata_filt$End/1e6, linetype="dotted", color = "orange", size=1.5) + 
    annotate(geom="label", x=peakMetadata_filt$Start/1e6, y=1, label=peakMetadata_filt$Peak,color="orange") + 
    (if (!is.null(g)) gggrid::grid_panel(g)) + 
    xlab(xlab) +
    theme_classic() +
    theme(axis.text = element_text(colour = "black", size = 10 * cex.axis),
          axis.title = element_text(size = 10 * cex.lab),
          axis.line.y = element_blank(),
          axis.text.y = element_blank(),
          axis.title.y = element_blank(),
          axis.ticks.y = element_blank()) +
    #xlim(loc$xrange[1] / 1e6, loc$xrange[2] / 1e6)
    if (!xticks) {
      g2 <- g2 +
        theme(axis.line.x = element_blank(),
              axis.ticks.x = element_blank(),
              axis.text.x = element_blank())
    }
  g2 
}


ld_reflookup <- function(rsid, pop='EUR', opengwas_jwt=get_opengwas_jwt())
{
  res <- api_query('ld/reflookup',
                   query = list(
                     rsid = rsid,
                     pop = pop
                   ),
                   opengwas_jwt=opengwas_jwt
  ) %>% get_query_content()
  if(length(res) == 0)
  {
    res <- character(0)
  }
  return(res)
}


library(locuszoomr)
library(dplyr)
library(tidyr)
library(readr)
library(reshape)
library(data.table)
library(coloc)
library(qvalue)
library(GenomicRanges)
library(R.utils)
library(jjb)
library(stringr)
library(TwoSampleMR)
library(ieugwasr)
library(ggplot2)
library(EnsDb.Hsapiens.v86)
library(splitstackshape)

args = commandArgs(trailingOnly=TRUE)

chrom = args[1]

#read in loop file
loopFile <- fread("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/manuscript_review_analyses/caQTL_coloc_only_examples/caQTLonly_df_forPlot_Heart_Left_Ventricle_102_irnt.txt")
pheno <- unique(loopFile$V6)
tissue <- unique(loopFile$V2)

#read in key
key = fread("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/phenoKeyForFigures.txt",header=F)

#get pheno info
phenoInfo=key %>% dplyr::filter(V1==pheno)
keyTrait = as.character(phenoInfo$V2)

#read in peak metadata
peakMetadata <- read.table("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/inputFiles/cpm_peakInfo.txt",header=T)




#read in eqtl data

eqtl <- fread(paste0("/project/voight_datasets_01/GTEx_v8/TissueSpecific/",tissue,".allpairs.txt.gz"),header=T)






loopFile_chr <- loopFile %>% dplyr::filter(V5 == chrom)

if (nrow(loopFile_chr) >0){
  #read in rsid file loop
  all_idFile <- data.frame()
  idFile <- fread(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/kaviar_af/Kaviar-160204-Public/vcfs/Kaviar-160204-Public-hg38-trim.noHead.vcf.chr",chrom,".vcf.gz"))
  idFile$variant <- paste0(idFile$V1,"_",idFile$V2,"_",idFile$V4,"_",idFile$V5,"_b38")
  all_idFile <- rbind(all_idFile,idFile)
  
  #read in gwas data
  
  gwas = read_delim(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/chosenTraits_bw/",pheno,"/",pheno,"_hg38_chr",chrom,".txt.gz"),delim="\t",col_names=TRUE)
  gwas$chr = gwas$seqnames
  
  
  newVariant<-paste0(gwas$seqnames,":",gwas$start,":",gwas$major_allele,":",gwas$minor_allele)
  
  newVariant<-as.data.frame(newVariant)
  gwas<-cbind(gwas,newVariant)
  gwas$pos=gwas$start
  
  gwas$SNP = gsub(":","_",gwas$newVariant)
  #gwas$EA = toupper(gwas$EA)
  #gwas$NEA = toupper(gwas$NEA)
  #gwas$SE = gwas$StdErr
  #gwas$zScore_gwas = (gwas$Beta/gwas$StdErr)
  gwas$variant = paste(gwas$SNP,"b38",sep="_")
  gwas$match <- paste0(gwas$seqnames,":",gwas$start)
  gwas$finalVar <- paste0("chr",gwas$variant)
  
  #read in caqtl data
  multiTissue_stats = fread(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/tensorQTL/prinComp_200/plink_maf_filter_test/tensorqtl_yuanAllSamples_4.10.24_prinComp200_allTests_allChr.cis_qtl_pairs.",chrom,".FDR5.peaks.txt"),header=T)
  colnames(multiTissue_stats) = c('phenotype_id','variant_id','start_distance','end_distance','af','ma_samples','ma_count','pval_nominal','slope','slope_se')
  
  #read in AF data loop
  allMultiTissueAF <- data.frame()
  
  multiTissueAF = read.table(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/tensorQTL/genotype/chr",chrom,".allFinalSamples.AF_filesForColocFinal.txt"),header=T)
  multiTissueAF = within(multiTissueAF, INFO<-data.frame(do.call('rbind', strsplit(as.character(INFO), '=', fixed=TRUE))))
  AF=as.character(multiTissueAF$INFO$X4)
  multiTissueAF$MAF = as.numeric(AF)
  multiTissueAF$match <- paste0(multiTissueAF$CHROM,":",multiTissueAF$POS)
  
  allMultiTissueAF <- rbind(allMultiTissueAF,multiTissueAF)
  
  #for (q in (1:nrow(loopFile_chr))){
  for (q in peakRows){
    
    loopFileRow <- loopFile_chr[q]
    
    multiTissue_peak <- loopFileRow$V1
    gene <- loopFileRow$V3
    geneName <- loopFileRow$V7
    
    caqtl_loc <- data.frame()
    
    if (file.exists(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/manuscript_review_analyses/caQTL_coloc_only_examples/Figures/",multiTissue_peak,"_",tissue,"_",geneName,"_",keyTrait,".pdf"))){
      print("done")
    }else{
      
      #get metadata for peak of interest
      peakMetadata_filt <- peakMetadata %>% dplyr::filter(Peak == multiTissue_peak )
      
      #filter on gene id  
      eqtl_gene <- eqtl %>% dplyr::filter(gene_id==gene)
      eqtl_gene$variant = gsub("chr","",eqtl_gene$variant_id)
      
      
      
      multiTissue_stats_peak <- multiTissue_stats %>% dplyr::filter(phenotype_id==multiTissue_peak)
      #multiTissue_stats$pos=multiTissueFinal$POS
      multiTissue_stats_peak$chrom=chrom
      multiTissue_stats_peak$rsid=multiTissue_stats_peak$variant_id
      multiTissue_stats_peak$p=multiTissue_stats_peak$pval_nominal
      
      multiTissueFinal = merge(allMultiTissueAF, multiTissue_stats_peak, by.x='ID', by.y='variant_id')
      multiTissueFinal$variant <- paste0(multiTissueFinal$CHROM,"_",multiTissueFinal$POS,"_",multiTissueFinal$REF,"_",multiTissueFinal$ALT,"_b38")
      multiTissueFinal$pos=multiTissueFinal$POS
      
      
      #merge eqtl and caqtl data
      m = merge(eqtl_gene, multiTissueFinal, by="variant")
      
      if (nrow(m)>0){
        print("m")
        #print(m)
        print(nrow(m))
        
        
        #merge caqtl and gwas
        z <- merge(gwas, multiTissueFinal, by="match")
        
        #filter z to keep only snps in LD reference panel
        open_gwas_jwt="eyJhbGciOiJSUzI1NiIsImtpZCI6ImFwaS1qd3QiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJhcGkub3Blbmd3YXMuaW8iLCJhdWQiOiJhcGkub3Blbmd3YXMuaW8iLCJzdWIiOiJid2VuekB1cGVubi5lZHUiLCJpYXQiOjE3Mjc0NTI1MDksImV4cCI6MTcyODY2MjEwOX0.YWGQEQtByy_6_cTcdO164A0uRJufx9Cgr1uGuNeHTgTuHIfpKYS9ba-kFTKH2pg5b2hen9UNCMFrfA7Zue4Fy9Ux9sP_ttTiuaxHrnLjZzRqeFPL9lk4oGP3tfOJvHcNeo5VScJoaQD7wKq-lj2-Z0wVBMMnjxaeSHLgFDVC_5FtE6ngvGl247S_qAsUDc5ys1YgAG10LmPCFevikaRUjRNatJ5XwlHHu5ssNayBm2eqwZphMUcDXJ_dBIga_vX_xfeNA_5CokKcuCaF62nfV-5fu-h9KqgaQRB2AGqQfQJlqIYi6pxPWdxZT-q1_wPLG96VNxSs2NrPKJMvWS7L9g"
        snpsToKeep <- ld_reflookup(z$rsid,opengwas_jwt=open_gwas_jwt)
        z_final <- z %>% dplyr::filter(rsid %in% snpsToKeep)
        #print(head(z_final))
        
        #get plotting objects
        
        tryCatch({
          caqtl_loc <- locus(data = m, gene = geneName,ens_db = "EnsDb.Hsapiens.v86",chrom="chrom",pos="pos",labs="rsid",p="pval_nominal.y",flank = 1e5)
          
          
          if (is.null(caqtl_loc$data)){
            
            caqtl_loc <- locus(data = m, gene = geneName,ens_db = "EnsDb.Hsapiens.v86",chrom="chrom",pos="pos",labs="rsid",p="pval_nominal.y",flank = 1e6)
            
            if (is.null(caqtl_loc$data)){
              print("skip")
            }else{
              
              caqtl_loc <- link_LD(caqtl_loc, token = "e16894448bcb")
              
              eqtl_loc <- locus(data = m, gene = geneName,ens_db = "EnsDb.Hsapiens.v86",chrom="chrom",pos="pos",labs="rsid",p="pval_nominal.x",flank = 1e6)
              eqtl_loc <- link_LD(eqtl_loc, token = "e16894448bcb")
              
              z_final$pos <- z_final$POS
              
              gwas_loc <- locus(data = z_final, gene = geneName,ens_db = "EnsDb.Hsapiens.v86",chrom="chrom",pos="pos",labs="rsid",p="pval",flank = 1e6)
              gwas_loc <- link_LD(gwas_loc, token = "e16894448bcb")
              
              
              #all eqtl plot
              #eqtl <- cSplit(eqtl,"variant","_")
              #allMultiTissueAF$eqtlMatch <- paste0("chr",allMultiTissueAF$CHROM,"_",allMultiTissueAF$POS,"_",allMultiTissueAF$REF,"_",allMultiTissueAF$ALT,"_b38")
              
              
              
              eqtlFinal = merge(all_idFile, eqtl_gene, by='variant')
              
              #get plot object
              eqtl_overlay_loc <- locus(data = eqtlFinal, gene = geneName,ens_db = "EnsDb.Hsapiens.v86",chrom="V1",pos="V2",labs="V3",p="pval_nominal",flank = 1e6)
              eqtl_overlay_loc <- link_LD(eqtl_overlay_loc, token = "e16894448bcb")
              
              #loc2 <- link_eqtl(eqtl_overlay_loc, token = "e16894448bcb")
              
              
              
              
              #all gwas plot
              gwasFinal = merge(all_idFile, gwas, by='variant')
              
              gwasFinal_filt <- gwasFinal %>% dplyr::filter(pos > (peakMetadata_filt$Start-2000000) & pos < (peakMetadata_filt$End+2000000))
              gwasFinal_filt <- gwasFinal %>% dplyr::filter(!V3==".")
              gwasFinal_filt <- gwasFinal %>% dplyr::filter(!pval=="NA")
              
              all_gwas_loc <- locus(data = gwasFinal_filt, gene = geneName,ens_db = "EnsDb.Hsapiens.v86",chrom="chr",pos="pos",labs="V3",p="pval",flank = 1e6)
              
              all_gwas_loc <- link_LD(all_gwas_loc, token = "e16894448bcb")
              
              
              library(cowplot)
              p1 <- gg_scatter(legend="right",caqtl_loc,size=3,cex.axis = 1.5,cex.lab = 1.5, pcutoff=F,labels = "index",nudge_x = 0.03, ylab=paste0("Coloc ",multiTissue_peak,"\n-log10( caQTL p value)")) +theme(axis.title.y=element_text(angle=0,vjust = 0.5))
              p2 <- gg_scatter(legend="right",eqtl_loc,size=3,cex.axis = 1.5,cex.lab = 1.5, pcutoff=F,labels = "index", nudge_x = 0.03,ylab=paste0("Coloc GTEx ",tissue," ",geneName, "\n-log10(eQTL p value)"))+theme(axis.title.y=element_text(angle=0,vjust = 0.5))
              p5 <- gg_scatter(legend="right",gwas_loc,size=3, cex.axis = 1.5,cex.lab = 1.5,pcutoff=F,labels = "index", nudge_x = 0.03,ylab=paste0("Coloc ",keyTrait,"\n -log10(GWAS p value)"))+theme(axis.title.y=element_text(angle=0,vjust = 0.5))
              p3 <- gg_scatter(legend="right",eqtl_overlay_loc,size=3, cex.axis = 1.5,cex.lab = 1.5,pcutoff=F,labels = "index", nudge_x = 0.03,ylab=paste0("GTEx ",tissue," ",geneName,"\n-log10(eQTL p value)"))+theme(axis.title.y=element_text(angle=0,vjust = 0.5))
              p6 <- gg_scatter(legend="right",all_gwas_loc,size=3,cex.axis = 1.5,cex.lab = 1.5,pcutoff=F, labels = "index", nudge_x = 0.03,ylab=paste0(keyTrait,"\n -log10(GWAS p value)"))+theme(axis.title.y=element_text(angle=0,vjust = 0.5))
              p4 <- gg_genetracks(caqtl_loc,cex.lab=1.5,cex.axis = 1.5,cex.text=1.5) 
              
              plot_grid(p1, p2, p5, p3, p6, p4, ncol = 1,align = "v")
              
              ggsave(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/manuscript_review_analyses/caQTL_coloc_only_examples/Figures/",multiTissue_peak,"_",tissue,"_",geneName,"_",keyTrait,".pdf"), width = 12, height = 18)
              
            }
            
            
            
          }else{
            print("1e5")
            
            caqtl_loc <- link_LD(caqtl_loc, token = "e16894448bcb")
            
            eqtl_loc <- locus(data = m, gene = geneName,ens_db = "EnsDb.Hsapiens.v86",chrom="chrom",pos="pos",labs="rsid",p="pval_nominal.x",flank = 1e5)
            eqtl_loc <- link_LD(eqtl_loc, token = "e16894448bcb")
            
            z_final$pos <- z_final$POS
            
            gwas_loc <- locus(data = z_final, gene = geneName,ens_db = "EnsDb.Hsapiens.v86",chrom="chrom",pos="pos",labs="rsid",p="pval",flank = 1e5)
            gwas_loc <- link_LD(gwas_loc, token = "e16894448bcb")
            
            
            #all eqtl plot
            #eqtl <- cSplit(eqtl,"variant","_")
            #allMultiTissueAF$eqtlMatch <- paste0("chr",allMultiTissueAF$CHROM,"_",allMultiTissueAF$POS,"_",allMultiTissueAF$REF,"_",allMultiTissueAF$ALT,"_b38")
            
            
            
            eqtlFinal = merge(all_idFile, eqtl_gene, by='variant')
            
            #get plot object
            eqtl_overlay_loc <- locus(data = eqtlFinal, gene = geneName,ens_db = "EnsDb.Hsapiens.v86",chrom="V1",pos="V2",labs="V3",p="pval_nominal",flank = 1e5)
            eqtl_overlay_loc <- link_LD(eqtl_overlay_loc, token = "e16894448bcb")
            
            #loc2 <- link_eqtl(eqtl_overlay_loc, token = "e16894448bcb")
            
            
            
            
            #all gwas plot
            gwasFinal = merge(all_idFile, gwas, by='variant')
            
            
            gwasFinal_filt <- gwasFinal %>% dplyr::filter(pos > (peakMetadata_filt$Start-2000000) & pos < (peakMetadata_filt$End+2000000))
            gwasFinal_filt <- gwasFinal %>% dplyr::filter(!V3==".")
            gwasFinal_filt <- gwasFinal %>% dplyr::filter(!pval=="NA")
            
            
            all_gwas_loc <- locus(data = gwasFinal_filt, gene = geneName,ens_db = "EnsDb.Hsapiens.v86",chrom="chr",pos="pos",labs="V3",p="pval",flank = 1e5)
            all_gwas_loc <- link_LD(all_gwas_loc, token = "e16894448bcb")
            
            
            library(cowplot)
            p1 <- gg_scatter(legend="right",caqtl_loc,size=3,cex.axis = 1.5,cex.lab = 1.5, pcutoff=F,labels = "index",nudge_x = 0.03, ylab=paste0("Coloc ",multiTissue_peak,"\n-log10( caQTL p value)")) +theme(axis.title.y=element_text(angle=0,vjust = 0.5))
            p2 <- gg_scatter(legend="right",eqtl_loc,size=3,cex.axis = 1.5,cex.lab = 1.5, pcutoff=F,labels = "index", nudge_x = 0.03,ylab=paste0("Coloc GTEx ",tissue," ",geneName, "\n-log10(eQTL p value)"))+theme(axis.title.y=element_text(angle=0,vjust = 0.5))
            p5 <- gg_scatter(legend="right",gwas_loc,size=3, cex.axis = 1.5,cex.lab = 1.5,pcutoff=F,labels = "index", nudge_x = 0.03,ylab=paste0("Coloc ",keyTrait,"\n -log10(GWAS p value)"))+theme(axis.title.y=element_text(angle=0,vjust = 0.5))
            p3 <- gg_scatter(legend="right",eqtl_overlay_loc,size=3, cex.axis = 1.5,cex.lab = 1.5,pcutoff=F,labels = "index", nudge_x = 0.03,ylab=paste0("GTEx ",tissue," ",geneName,"\n-log10(eQTL p value)"))+theme(axis.title.y=element_text(angle=0,vjust = 0.5))
            p6 <- gg_scatter(legend="right",all_gwas_loc,size=3,cex.axis = 1.5,cex.lab = 1.5,pcutoff=F, labels = "index", nudge_x = 0.03,ylab=paste0(keyTrait,"\n -log10(GWAS p value)"))+theme(axis.title.y=element_text(angle=0,vjust = 0.5))
            p4 <- gg_genetracks(caqtl_loc,cex.lab=1.5,cex.axis = 1.5,cex.text=1.5) 
            
            plot_grid(p1, p2, p5, p3, p6, p4, ncol = 1,align = "v")
            
            ggsave(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/manuscript_review_analyses/caQTL_coloc_only_examples/Figures/",multiTissue_peak,"_",tissue,"_",geneName,"_",keyTrait,".pdf"), width = 12, height = 18)
          }
        }, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
      }
    }
  }
  
}else{
  
  print("no peaks")
}




#######################################################################################
#####Supplementary Figure 17 - Proportion of GWAS Signals explained by eQTLs/caQTLs####
#######################################################################################

library(ggplot2)
library(tidyr)
library(data.table)
library(forcats)
library(dplyr)


#read in data
x <- read.table("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/caqtl_eqtl_coloc/newGTF/allPheno_allTissue_gwas_eqtl_colocStats.10.19.24.txt",header=T,sep='\t')

#add proportions explained
x$prop_gwas_caqtl <- (x$Lead_GWAS_Variants_Colocalize_with_caQTL_and_eQTL+x$Lead_GWAS_Variants_Colocalize_with_caQTL_Only)/x$Independent_Lead_GWAS_Signals_Tested
x$prop_gwas_eqtl <- (x$Lead_GWAS_Variants_Colocalize_with_caQTL_and_eQTL+x$Lead_GWAS_Variants_Colocalize_with_eQTL_Only)/x$Independent_Lead_GWAS_Signals_Tested
x$prop_gwas_total <- (x$Lead_GWAS_Variants_Colocalize_with_caQTL_and_eQTL+x$Lead_GWAS_Variants_Colocalize_with_eQTL_Only+x$Lead_GWAS_Variants_Colocalize_with_caQTL_Only)/x$Independent_Lead_GWAS_Signals_Tested

#pivot to longer format
y <- pivot_longer(x,c("prop_gwas_caqtl","prop_gwas_eqtl","prop_gwas_total"))
y <- as.data.frame(y)
y$name <- factor(y$name,levels=c("prop_gwas_caqtl","prop_gwas_eqtl","prop_gwas_total"),ordered=TRUE)
y$name <- gsub("prop_gwas_caqtl","Proportion of GWAS Signals Explained by Global caQTLs",y$name)
y$name <- gsub("prop_gwas_eqtl","Proportion of GWAS Signals Explained by eQTLs",y$name)
y$name <- gsub("prop_gwas_total","Proportion of GWAS Signals Explained by Global caQTLs and eQTLs",y$name)
y <- y %>% mutate(name = fct_relevel(name,c('Proportion of GWAS Signals Explained by Global caQTLs and eQTLs','Proportion of GWAS Signals Explained by eQTLs','Proportion of GWAS Signals Explained by Global caQTLs')))

#plot
p <- ggplot(y, aes(x=value, y=name,fill=name)) + geom_boxplot() + ggtitle("Proportion of GWAS Explained by Global caQTLs and eQTLs") 
p <- p + theme(legend.position="none") + theme(axis.title.x=element_blank(), axis.title.y=element_blank()) + theme(plot.title = element_text(hjust = 0.5))
ggsave("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Figures/supplementary_proportion_gwas_explained_boxplot.10.21.24.png",p,height=6,width=10,dpi=1200,unit='in')





###################################################################################
#####Supplementary Figure 18 - Genomic Annotations of colocalization categories####
###################################################################################

library(reshape)
library(ggplot2)

#read in data
threeWay <- read.table("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Analyses/colocalization_category_peakAnnotations_6.3.24/lead_caqtl_window_version/eqtl_caQTL_overlap_regions_allPheno_allTissues_peakAnnotations.realRegions_vs_random_1000iterations.stats.10.21.24.txt",header=T)
eqtl <- read.table("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Analyses/colocalization_category_peakAnnotations_6.3.24/lead_caqtl_window_version/eqtl_only_peaks_allPheno_allTissues_peakAnnotations.realRegions_vs_random_1000iterations.stats.10.21.24.txt",header=T)
caqtl <- read.table("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Analyses/colocalization_category_peakAnnotations_6.3.24/lead_caqtl_window_version/caQTL_only_regions_allPheno_allTissues_peakAnnotations.realRegions_vs_random_1000iterations.stats.10.21.24.txt",header=T)

#calculate enrichment
caqtl$enrichment <- caqtl$caQTL_Peak/caqtl$Random
eqtl$enrichment <- eqtl$eQTL_region/eqtl$Random
threeWay$enrichment <- threeWay$caQTL_Peak/threeWay$Random

#get df subset
caqtl_enrich <- data.frame(caqtl$Annotation,caqtl$enrichment,"caQTL_GWAS_only_coloc")
colnames(caqtl_enrich) <- c("Annotation","Enrichment","Type")

eqtl_enrich <- data.frame(eqtl$Annotation,eqtl$enrichment,"eQTL_GWAS_only_coloc")
colnames(eqtl_enrich) <- c("Annotation","Enrichment","Type")

threeWay_enrich <- data.frame(threeWay$Annotation,threeWay$enrichment,"eQTL_caQTL_GWAS_coloc")
colnames(threeWay_enrich) <- c("Annotation","Enrichment","Type")


#merge all categories
df_list <- list(caqtl_enrich,eqtl_enrich,threeWay_enrich)


final <- merge_recurse(df_list)


p=ggplot(final,aes(x=Annotation,y=Enrichment,fill=Type)) +  geom_bar(stat="identity",position="dodge") + ylab("Enrichment (Fold Change)")+ theme_bw()+ theme(plot.title = element_text( size=15, face="bold.italic"),axis.title.y = element_text( size=10, face="bold"), axis.text.x = element_text(face="bold", size=8),axis.text.y = element_text(face="bold", size=8)) + theme(axis.text.x = element_text(angle = 45, hjust=1)) + theme(legend.title = element_text(size = 8),legend.text = element_text(size = 8))+theme(plot.margin = margin(1,1,1.5,1.2, "cm")) + ggtitle("Genomic Annotations of Colocalizations")

ggsave("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Analyses/colocalization_category_peakAnnotations_6.3.24/lead_caqtl_window_version/all_coloc_varieties_allPheno_allTissues_peakAnnotations.realRegions_vs_random_1000iterations.caQTL_regionVersion.10.21.24.png",p,width=9,height=7,dpi=1200)





#########################################################################################
#####Supplementary Figure 19 - Genomic Annotations of GWAS/caQTL only colocalizations#####
#########################################################################################


library(data.table)
library(dplyr)
library(annotatr)
library(stringr)

#read in regions of interest
y<-read_regions(con=paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Analyses/colocalization_category_peakAnnotations_6.3.24/lead_caqtl_window_version/caQTL_only_regions_allPheno_allTissues.10.21.24.bed"),genome='hg38')


annots = c("hg38_genes_1to5kb","hg38_genes_promoters","hg38_genes_cds","hg38_genes_5UTRs","hg38_genes_exons","hg38_genes_firstexons","hg38_genes_introns","hg38_genes_intronexonboundaries","hg38_genes_3UTRs","hg38_genes_intergenic","hg38_enhancers_fantom","hg38_basicgenes")

# Build the annotations (a single GRanges object)
annotations = build_annotations(genome = 'hg38', annotations = annots)

# Intersect the regions we read in with the annotations
y_annotated = annotate_regions(
  regions = y,
  annotations = annotations,
  ignore.strand = TRUE,
  quiet = FALSE,minoverlap =100)

# A GRanges object is returned
#print(y_annotated)



df_dm_annotated = data.frame(y_annotated)

dm_annsum = summarize_annotations(
  annotated_regions = y_annotated,
  quiet = TRUE)
write.table(dm_annsum,"/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Analyses/colocalization_category_peakAnnotations_6.3.24/lead_caqtl_window_version/caQTL_only_regions_allPheno_allTissues_peakAnnotations.10.21.24.txt")


dm_annotated<-read.table("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Analyses/colocalization_category_peakAnnotations_6.3.24/lead_caqtl_window_version/caQTL_only_regions_allPheno_allTissues_peakAnnotations.10.21.24.txt")

annots_order = c("hg38_genes_1to5kb","hg38_genes_promoters","hg38_genes_cds","hg38_genes_5UTRs","hg38_genes_exons","hg38_genes_firstexons","hg38_genes_introns","hg38_genes_intronexonboundaries","hg38_genes_3UTRs","hg38_genes_intergenic","hg38_enhancers_fantom","hg38_basicgenes")

randomDF<-data.frame(dm_annotated$annot.type)
for (x in (1:1000)){
  # Randomize the input regions
  x <- read.table(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Analyses/colocalization_category_peakAnnotations_6.3.24/lead_caqtl_window_version/caQTL_specific_overlap_regions_allPheno_allTissues_background_size_gc_repeatMatched.",x,".10.21.24.bed"))
  x$V1 <- paste0("chr",x$V1)
  write.table(x,"/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Analyses/colocalization_category_peakAnnotations_6.3.24/lead_caqtl_window_version/caqtl_specific_gwas_regions.bed",row.names = F,col.names=F,sep='\t',quote=F)
  
  dm_random_regions<-read_regions(con=paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Analyses/colocalization_category_peakAnnotations_6.3.24/lead_caqtl_window_version/caqtl_specific_gwas_regions.bed"),genome='hg38')
  
  # Annotate the random regions using the same annotations as above
  # These will be used in later functions
  dm_random_annotated = annotate_regions(regions = dm_random_regions,annotations = annotations,ignore.strand = TRUE,quiet = TRUE,minoverlap =100)
  
  df_dm_random_annotated = data.frame(dm_random_annotated)
  
  dm_annsum_random = summarize_annotations(annotated_regions = dm_random_annotated,quiet = TRUE)
  
  dm_annsum_random<-as.data.frame(dm_annsum_random)
  
  randomDF<-merge(randomDF,dm_annsum_random,by.x='dm_annotated.annot.type',by.y='annot.type',all=T)
  
}  


finalDF<-merge(randomDF,dm_annotated,by.x="dm_annotated.annot.type",by.y="annot.type",all=T)
colnames(finalDF)<-c("Annotation",paste0("Random_",rep(1:1000)),"ATAC_Peak_Regions")

#get number of shuffled values greater than real values
for (q in 1:nrow(finalDF)){
  
  pValCount <- sum(colSums(finalDF[q,2:1001] >= finalDF[q,1002]))
  
  if (pValCount == 0){
    finalDF$pval_enriched[q] <- 1/1001
  }else{
    finalDF$pval_enriched[q] <- pValCount/1000
  }
  
  
  
  pValCount <- sum(colSums(finalDF[q,2:1001] >= finalDF[q,1002]))
  pValCount <- 1000-pValCount
  
  if (pValCount == 0){
    finalDF$pval_depleted[q] <- 1/1001
  }else{
    finalDF$pval_depleted[q] <- pValCount/1000
  }
  
}


finalDF<-as.data.frame(finalDF)
finalDF[is.na(finalDF)] <- 0
finalDF$RandomMedian <- apply(finalDF[,2:1001],1,median)

write.table(finalDF,"/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Analyses/colocalization_category_peakAnnotations_6.3.24/lead_caqtl_window_version/caQTL_only_regions_allPheno_allTissues_peakAnnotations.realRegions_vs_random_1000iterations.10.21.24.txt",col.names=T,row.names=F,quote=F,sep='\t')


finalDF_mod <- data.frame(finalDF$Annotation,finalDF$RandomMedian,finalDF$ATAC_Peak_Regions,finalDF$pval_enriched,finalDF$pval_depleted,(finalDF$ATAC_Peak_Regions/finalDF$RandomMedian))
colnames(finalDF_mod) <- c("Annotation","Random","caQTL_region","pval_enriched","pval_depleted","enrichment")
finalDF <- finalDF_mod

write.table(finalDF,"/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Analyses/colocalization_category_peakAnnotations_6.3.24/lead_caqtl_window_version/caQTL_only_regions_allPheno_allTissues_peakAnnotations.realRegions_vs_random_1000iterations.stats.10.21.24.txt",col.names=T,row.names=F,quote=F,sep='\t')

library(reshape)

dfForPlot<-melt(finalDF[,1:3], id=c("Annotation"))
dfForPlot<-as.data.frame(dfForPlot)
colnames(dfForPlot)<-c("Annotation","Set","RegionCount")
dfForPlot$RegionCount<-as.character(dfForPlot$RegionCount)
dfForPlot$RegionCount<-as.numeric(dfForPlot$RegionCount)

library(ggplot2)

p=ggplot(dfForPlot,aes(x=Annotation,y=RegionCount,fill=Set)) +  geom_bar(stat="identity",position="dodge") + ylab("count")+ theme_bw()+ theme(plot.title = element_text( size=15, face="bold.italic"),axis.title.y = element_text( size=10, face="bold"), axis.text.x = element_text(face="bold", size=8),axis.text.y = element_text(face="bold", size=8)) + theme(axis.text.x = element_text(angle = 45, hjust=1)) + theme(legend.title = element_text(size = 8),legend.text = element_text(size = 8))+theme(plot.margin = margin(1,1,1.5,1.2, "cm")) + ggtitle("Colocalizing GWAS/caQTL Only \nLead caQTL Genomic Annotations")

ggsave("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Analyses/colocalization_category_peakAnnotations_6.3.24/lead_caqtl_window_version/caQTL_only_regions_allPheno_allTissues_peakAnnotations.realRegions_vs_random_1000iterations.10.21.24.png",p,width=7,height=7,dpi=1200)





###############################################################################################
#####Supplementary Figure 20 - Genomic Annotations of GWAS/caQTL/eQTL only colocalizations######
###############################################################################################



library(data.table)
library(dplyr)
library(annotatr)
library(stringr)

#read in regions of interest
y<-read_regions(con=paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Analyses/colocalization_category_peakAnnotations_6.3.24/lead_caqtl_window_version/eqtl_caQTL_overlap_regions_allPheno_allTissues.10.21.24.bed"),genome='hg38')


annots = c("hg38_genes_1to5kb","hg38_genes_promoters","hg38_genes_cds","hg38_genes_5UTRs","hg38_genes_exons","hg38_genes_firstexons","hg38_genes_introns","hg38_genes_intronexonboundaries","hg38_genes_3UTRs","hg38_genes_intergenic","hg38_enhancers_fantom","hg38_basicgenes")

# Build the annotations (a single GRanges object)
annotations = build_annotations(genome = 'hg38', annotations = annots)

# Intersect the regions we read in with the annotations
y_annotated = annotate_regions(
  regions = y,
  annotations = annotations,
  ignore.strand = TRUE,
  quiet = FALSE,minoverlap =100)

# A GRanges object is returned
#print(y_annotated)



df_dm_annotated = data.frame(y_annotated)

dm_annsum = summarize_annotations(
  annotated_regions = y_annotated,
  quiet = TRUE)
write.table(dm_annsum,"/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Analyses/colocalization_category_peakAnnotations_6.3.24/lead_caqtl_window_version/eqtl_caQTL_overlap_regions_allPheno_allTissues_peakAnnotations.10.21.24.txt")


dm_annotated<-read.table("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Analyses/colocalization_category_peakAnnotations_6.3.24/lead_caqtl_window_version/eqtl_caQTL_overlap_regions_allPheno_allTissues_peakAnnotations.10.21.24.txt")

annots_order = c("hg38_genes_1to5kb","hg38_genes_promoters","hg38_genes_cds","hg38_genes_5UTRs","hg38_genes_exons","hg38_genes_firstexons","hg38_genes_introns","hg38_genes_intronexonboundaries","hg38_genes_3UTRs","hg38_genes_intergenic","hg38_enhancers_fantom","hg38_basicgenes")

randomDF<-data.frame(dm_annotated$annot.type)
for (x in (1:1000)){
  # Randomize the input regions
  #dm_random_regions = randomize_regions(regions = y,allow.overlaps = TRUE,per.chromosome = TRUE)
  x <- read.table(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Analyses/colocalization_category_peakAnnotations_6.3.24/lead_caqtl_window_version/eqtl_caQTL_overlap_regions_allPheno_allTissues_background_size_gc_repeatMatched.",x,".10.21.24.bed"))
  x$V1 <- paste0("chr",x$V1)
  write.table(x,"/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Analyses/colocalization_category_peakAnnotations_6.3.24/lead_caqtl_window_version/eqtl_caqtl_gwas_regions.bed",row.names = F,col.names=F,sep='\t',quote=F)
  
  dm_random_regions<-read_regions(con=paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Analyses/colocalization_category_peakAnnotations_6.3.24/lead_caqtl_window_version/eqtl_caqtl_gwas_regions.bed"),genome='hg38')
  
  
  # Annotate the random regions using the same annotations as above
  # These will be used in later functions
  dm_random_annotated = annotate_regions(regions = dm_random_regions,annotations = annotations,ignore.strand = TRUE,quiet = TRUE,minoverlap =100)
  
  df_dm_random_annotated = data.frame(dm_random_annotated)
  
  dm_annsum_random = summarize_annotations(annotated_regions = dm_random_annotated,quiet = TRUE)
  
  dm_annsum_random<-as.data.frame(dm_annsum_random)
  
  randomDF<-merge(randomDF,dm_annsum_random,by.x='dm_annotated.annot.type',by.y='annot.type',all=T)
  
}  


finalDF<-merge(randomDF,dm_annotated,by.x="dm_annotated.annot.type",by.y="annot.type",all=T)
colnames(finalDF)<-c("Annotation",paste0("Random_",rep(1:1000)),"ATAC_Peak_Regions")

#get number of shuffled values greater than real values
for (q in 1:nrow(finalDF)){
  
  pValCount <- sum(colSums(finalDF[q,2:1001] >= finalDF[q,1002]))
  
  if (pValCount == 0){
    finalDF$pval_enriched[q] <- 1/1001
  }else{
    finalDF$pval_enriched[q] <- pValCount/1000
  }
  
  
  
  pValCount <- sum(colSums(finalDF[q,2:1001] >= finalDF[q,1002]))
  pValCount <- 1000-pValCount
  
  if (pValCount == 0){
    finalDF$pval_depleted[q] <- 1/1001
  }else{
    finalDF$pval_depleted[q] <- pValCount/1000
  }
  
}


finalDF<-as.data.frame(finalDF)
finalDF[is.na(finalDF)] <- 0
finalDF$RandomMedian <- apply(finalDF[,2:1001],1,median)

write.table(finalDF,"/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Analyses/colocalization_category_peakAnnotations_6.3.24/lead_caqtl_window_version/eqtl_caQTL_overlap_regions_allPheno_allTissues_peakAnnotations.realRegions_vs_random_1000iterations.10.21.24.txt",col.names=T,row.names=F,quote=F,sep='\t')

finalDF_mod <- data.frame(finalDF$Annotation,finalDF$RandomMedian,finalDF$ATAC_Peak_Regions,finalDF$pval_enriched,finalDF$pval_depleted,(finalDF$ATAC_Peak_Regions/finalDF$RandomMedian))
colnames(finalDF_mod) <- c("Annotation","Random","caQTL_region","pval_enriched","pval_depleted","enrichment")
finalDF <- finalDF_mod

write.table(finalDF,"/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Analyses/colocalization_category_peakAnnotations_6.3.24/lead_caqtl_window_version/eqtl_caQTL_overlap_regions_allPheno_allTissues_peakAnnotations.realRegions_vs_random_1000iterations.stats.10.21.24.txt",col.names=T,row.names=F,quote=F,sep='\t')

library(reshape)

dfForPlot<-melt(finalDF[,1:3], id=c("Annotation"))
dfForPlot<-as.data.frame(dfForPlot)
colnames(dfForPlot)<-c("Annotation","Set","RegionCount")
dfForPlot$RegionCount<-as.character(dfForPlot$RegionCount)
dfForPlot$RegionCount<-as.numeric(dfForPlot$RegionCount)

library(ggplot2)

p=ggplot(dfForPlot,aes(x=Annotation,y=RegionCount,fill=Set)) +  geom_bar(stat="identity",position="dodge") + ylab("count")+ theme_bw()+ theme(plot.title = element_text( size=15, face="bold.italic"),axis.title.y = element_text( size=10, face="bold"), axis.text.x = element_text(face="bold", size=8),axis.text.y = element_text(face="bold", size=8)) + theme(axis.text.x = element_text(angle = 45, hjust=1)) + theme(legend.title = element_text(size = 8),legend.text = element_text(size = 8))+theme(plot.margin = margin(1,1,1.5,1.2, "cm")) + ggtitle("Colocalizing GWAS/caQTL/eQTL \n caQTL Region Genomic Annotations")

ggsave("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Analyses/colocalization_category_peakAnnotations_6.3.24/lead_caqtl_window_version/eqtl_caQTL_gwas_peaks_allPheno_allTissues_peakAnnotations.realRegions_vs_random_1000iterations.10.21.24.png",p,width=7,height=7,dpi=1200)





#########################################################################################
#####Supplementary Figure 21 - Genomic Annotations of GWAS/eQTL only colocalizations#####
#########################################################################################


library(data.table)
library(dplyr)
library(annotatr)
library(stringr)

#read in regions of interest
y<-read_regions(con=paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Analyses/colocalization_category_peakAnnotations_6.3.24/lead_caqtl_window_version/eqtl_only_peaks_allPheno_allTissues.10.21.24.bed"),genome='hg38')


annots = c("hg38_genes_1to5kb","hg38_genes_promoters","hg38_genes_cds","hg38_genes_5UTRs","hg38_genes_exons","hg38_genes_firstexons","hg38_genes_introns","hg38_genes_intronexonboundaries","hg38_genes_3UTRs","hg38_genes_intergenic","hg38_enhancers_fantom","hg38_basicgenes")

# Build the annotations (a single GRanges object)
annotations = build_annotations(genome = 'hg38', annotations = annots)

# Intersect the regions we read in with the annotations
y_annotated = annotate_regions(
  regions = y,
  annotations = annotations,
  ignore.strand = TRUE,
  quiet = FALSE,minoverlap =100)

# A GRanges object is returned
#print(y_annotated)



df_dm_annotated = data.frame(y_annotated)

dm_annsum = summarize_annotations(
  annotated_regions = y_annotated,
  quiet = TRUE)
write.table(dm_annsum,"/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Analyses/colocalization_category_peakAnnotations_6.3.24/lead_caqtl_window_version/eqtl_only_peaks_allPheno_allTissues_peakAnnotations.10.21.24.txt")


dm_annotated<-read.table("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Analyses/colocalization_category_peakAnnotations_6.3.24/lead_caqtl_window_version/eqtl_only_peaks_allPheno_allTissues_peakAnnotations.10.21.24.txt")

annots_order = c("hg38_genes_1to5kb","hg38_genes_promoters","hg38_genes_cds","hg38_genes_5UTRs","hg38_genes_exons","hg38_genes_firstexons","hg38_genes_introns","hg38_genes_intronexonboundaries","hg38_genes_3UTRs","hg38_genes_intergenic","hg38_enhancers_fantom","hg38_basicgenes")

randomDF<-data.frame(dm_annotated$annot.type)
for (x in (1:1000)){
  # Randomize the input regions
  #dm_random_regions = randomize_regions(regions = y,allow.overlaps = TRUE,per.chromosome = TRUE)
  
  x <- read.table(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Analyses/colocalization_category_peakAnnotations_6.3.24/lead_caqtl_window_version/eQTL_specific_overlap_regions_allPheno_allTissues_background_size_gc_repeatMatched.",x,".10.21.24.bed"))
  x$V1 <- paste0("chr",x$V1)
  write.table(x,"/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Analyses/colocalization_category_peakAnnotations_6.3.24/lead_caqtl_window_version/eqtl_specific_gwas_regions.bed",row.names = F,col.names=F,sep='\t',quote=F)
  
  dm_random_regions<-read_regions(con=paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Analyses/colocalization_category_peakAnnotations_6.3.24/lead_caqtl_window_version/eqtl_specific_gwas_regions.bed"),genome='hg38')
  
  
  # Annotate the random regions using the same annotations as above
  # These will be used in later functions
  dm_random_annotated = annotate_regions(regions = dm_random_regions,annotations = annotations,ignore.strand = TRUE,quiet = TRUE,minoverlap =100)
  
  df_dm_random_annotated = data.frame(dm_random_annotated)
  
  dm_annsum_random = summarize_annotations(annotated_regions = dm_random_annotated,quiet = TRUE)
  
  dm_annsum_random<-as.data.frame(dm_annsum_random)
  
  randomDF<-merge(randomDF,dm_annsum_random,by.x='dm_annotated.annot.type',by.y='annot.type',all=T)
  
}  


finalDF<-merge(randomDF,dm_annotated,by.x="dm_annotated.annot.type",by.y="annot.type",all=T)
colnames(finalDF)<-c("Annotation",paste0("Random_",rep(1:1000)),"eQTL_region")

#get number of shuffled values greater than real values
for (q in 1:nrow(finalDF)){
  
  pValCount <- sum(colSums(finalDF[q,2:1001] >= finalDF[q,1002]))
  
  if (pValCount == 0){
    finalDF$pval_enriched[q] <- 1/1001
  }else{
    finalDF$pval_enriched[q] <- pValCount/1000
  }
  
  
  
  pValCount <- sum(colSums(finalDF[q,2:1001] >= finalDF[q,1002]))
  pValCount <- 1000-pValCount
  
  if (pValCount == 0){
    finalDF$pval_depleted[q] <- 1/1001
  }else{
    finalDF$pval_depleted[q] <- pValCount/1000
  }
  
}


finalDF<-as.data.frame(finalDF)
finalDF[is.na(finalDF)] <- 0
finalDF$RandomMedian <- apply(finalDF[,2:1001],1,median)

write.table(finalDF,"/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Analyses/colocalization_category_peakAnnotations_6.3.24/lead_caqtl_window_version/eqtl_only_peaks_allPheno_allTissues_peakAnnotations.realRegions_vs_random_1000iterations.10.21.24.txt",col.names=T,row.names=F,quote=F,sep='\t')

finalDF_mod <- data.frame(finalDF$Annotation,finalDF$RandomMedian,finalDF$eQTL_region,finalDF$pval_enriched,finalDF$pval_depleted,(finalDF$eQTL_region/finalDF$RandomMedian))
colnames(finalDF_mod) <- c("Annotation","Random","eQTL_region","pval_enriched","pval_depleted","enrichment")
finalDF <- finalDF_mod

write.table(finalDF,"/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Analyses/colocalization_category_peakAnnotations_6.3.24/lead_caqtl_window_version/eqtl_only_peaks_allPheno_allTissues_peakAnnotations.realRegions_vs_random_1000iterations.stats.10.21.24.txt",col.names=T,row.names=F,quote=F,sep='\t')

library(reshape)

dfForPlot<-melt(finalDF[,1:3], id=c("Annotation"))
dfForPlot<-as.data.frame(dfForPlot)
colnames(dfForPlot)<-c("Annotation","Set","RegionCount")
dfForPlot$RegionCount<-as.character(dfForPlot$RegionCount)
dfForPlot$RegionCount<-as.numeric(dfForPlot$RegionCount)

library(ggplot2)

p=ggplot(dfForPlot,aes(x=Annotation,y=RegionCount,fill=Set)) +  geom_bar(stat="identity",position="dodge") + ylab("count")+ theme_bw()+ theme(plot.title = element_text( size=15, face="bold.italic"),axis.title.y = element_text( size=10, face="bold"), axis.text.x = element_text(face="bold", size=8),axis.text.y = element_text(face="bold", size=8)) + theme(axis.text.x = element_text(angle = 45, hjust=1)) + theme(legend.title = element_text(size = 8),legend.text = element_text(size = 8))+theme(plot.margin = margin(1,1,1.5,1.2, "cm")) + ggtitle("Colocalizing GWAS/eQTL Only \n eQTL Region Genomic Annotations")

ggsave("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Analyses/colocalization_category_peakAnnotations_6.3.24/lead_caqtl_window_version/eqtl_only_peaks_allPheno_allTissues_peakAnnotations.realRegions_vs_random_1000iterations.10.21.24.png",p,width=7,height=7,dpi=1200)





################################################################################################
#####Supplementary Figures 22,23 - Single eQTL Tissue GWAS, caQTL, eQTLColocalization Stats#####
################################################################################################

#R
library(data.table)
library(dplyr)
library(tidyverse)
library(splitstackshape)

clump_par = 0.01



key = read.table("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/phenoKey.txt")
#key$V2 <- gsub("Neutrophill","Neutrophil",key$V2)
#key$V2 <- gsub("Eosinophill","Eosinophil",key$V2)

gwasLeads <- fread("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/chosenTraits_bw/allLeadGwas.txt")
gwasLeads <- cSplit(gwasLeads,"V2",sep="/")



for (tissue in c("Whole_Blood","Brain_Cortex")){
  allPhenoTissue <- data.frame()
  for (pheno in key$V1){
    allTissueDF <- data.frame()
    phenoInfo=key %>% dplyr::filter(V1==pheno)
    print(phenoInfo)
    keyTrait = as.character(phenoInfo$V2)
    print(keyTrait)
    
    leadDF <- gwasLeads %>% dplyr::filter(V2_1==pheno)
    lead_gwas_num <- leadDF$V1
    
    
    gwas_eqtl_coloc_filt <- data.frame()
    if (file.info(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/caqtl_eqtl_coloc/newGTF/eQTL_GWAS/",pheno,"_",tissue,"_all_chr.eQTL_coloc.pruned.0.01.newGTF.8.21.24.old_new.filtered.txt"))$size > 1){
      gwas_eqtl_coloc_filt <- fread(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/caqtl_eqtl_coloc/newGTF/eQTL_GWAS/",pheno,"_",tissue,"_all_chr.eQTL_coloc.pruned.0.01.newGTF.8.21.24.old_new.filtered.txt"))
      traitsInFile <- (length(unique(gwas_eqtl_coloc_filt$Trait)))
    }
    
    #remove chr from lead gwas
    gwas_eqtl_coloc_filt$leadGwasVariant <- gsub("chr","",gwas_eqtl_coloc_filt$leadGwasVariant)
    
    
    #read in caqtl-gwas
    caQTL_colocs <- data.frame()
    if (file.exists(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/chosenTraits_bw/",pheno,"_colocResults/",keyTrait,"_",pheno,"_multiTissue_allPeaks_coloc.pruned.",clump_par,"_allColocResults.Final.filtered.withStats.10.19.24.txt"))){
      
      caQTL_colocs <- fread(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/chosenTraits_bw/",pheno,"_colocResults/",keyTrait,"_",pheno,"_multiTissue_allPeaks_coloc.pruned.",clump_par,"_allColocResults.Final.filtered.withStats.10.19.24.txt"))
      
    }
    
    
    
    overlap <- data.frame()
    caqtl_specific <- data.frame()
    eqtl_specific <- data.frame()
    caQTL_only_df <- data.frame()
    clusterDF <- data.frame()
    
    if (nrow(gwas_eqtl_coloc_filt) >0 & nrow(caQTL_colocs) >0 ){
      #get overlap
      overlap <- intersect(caQTL_colocs$gwas_lead,gwas_eqtl_coloc_filt$leadGwasVariant)
      
      #get caqtl and eqtl specific lead gwas variant colocs
      caqtl_specific <- setdiff(caQTL_colocs$gwas_lead,gwas_eqtl_coloc_filt$leadGwasVariant)
      eqtl_specific <- setdiff(gwas_eqtl_coloc_filt$leadGwasVariant,caQTL_colocs$gwas_lead)
      
      #get data frame for caQTL only gwas colocalization
      caQTL_only_df <- caQTL_colocs %>% dplyr::filter(gwas_lead %in% caqtl_specific)
      
      
      clusterDF <- data.frame(keyTrait,length(overlap),length(caqtl_specific),nrow(caQTL_colocs),length(eqtl_specific),nrow(gwas_eqtl_coloc_filt),lead_gwas_num)
      colnames(clusterDF) <- c("Pheno","Lead GWAS Signals Colocalized with caQTL and eQTL","Lead GWAS Signals Colocalized with caQTL Only","Total Number of caQTL/GWAS Colocalizations","Lead GWAS Signals Colocalized with eQTL Only","Total Number of eQTL/GWAS Colocalizations","Independent Lead GWAS Signals Tested")
      
      clusterDF <- na.omit(clusterDF)
      
      allPhenoTissue <- rbind(allPhenoTissue,clusterDF)
      print("tissues")
      print(length(unique(allTissueDF$Tissue)))
    }
  }
  
  
  stats<-allPhenoTissue
  stats <- unique(stats)
  
  
  colnames(stats) <- gsub(" ","_",colnames(stats))
  colnames(stats) <- gsub("/","_",colnames(stats))
  stats <- as.data.frame(stats)
  
  #modify analysis column values
  stats$Pheno <- gsub("Non_cancer_illness_code_","",stats$Pheno)
  stats$Pheno <- gsub("Blood_clot_DVT_bronchitis_emphysema_asthma_rhinitis_eczema_allergy_diagnosed_by_doctor_","",stats$Pheno)
  stats$Pheno <- gsub("Vascular_heart_problems_diagnosed_by_doctor_","",stats$Pheno)
  stats$Pheno <- gsub("_"," ",stats$Pheno)
  stats$Pheno <- str_to_title(stats$Pheno)
  stats$Pheno <- gsub("Neutrophill","Neutrophil",stats$Pheno)
  stats$Pheno <- gsub("Eosinophill","Eosinophil",stats$Pheno)
  
  

  #modify analysis column values
  #define columns we want to extract
  columns <- c(1:3,5)
  
  stats_subset_var_final <- stats[,columns]
  stats_subset_var_final$Pheno <- make.unique(stats_subset_var_final$Pheno)
  stats_subset_var_final$Pheno <- gsub("Non_cancer_illness_code_","",stats_subset_var_final$Pheno)
  stats_subset_var_final$Pheno <- gsub("Blood_clot_DVT_bronchitis_emphysema_asthma_rhinitis_eczema_allergy_diagnosed_by_doctor_","",stats_subset_var_final$Pheno)
  stats_subset_var_final$Pheno <- gsub("Vascular_heart_problems_diagnosed_by_doctor_","",stats_subset_var_final$Pheno)
  stats_subset_var_final$Pheno <- gsub("Neutrophill","Neutrophil",stats_subset_var_final$Pheno)
  stats_subset_var_final$Pheno <- gsub("Eosinophill","Eosinophil",stats_subset_var_final$Pheno)
  stats_subset_var_final$Pheno <- gsub("_"," ",stats_subset_var_final$Pheno)
  stats_subset_var_final$Pheno <- str_to_title(stats_subset_var_final$Pheno)
  colnames(stats_subset_var_final) <- gsub("_"," ",colnames(stats_subset_var_final))
  
  tissue=gsub("_"," ",tissue)
  
  
  finalToPlot <- stats_subset_var_final %>% mutate(Label = Pheno) %>% reshape2::melt(.)
  finalToPlot$group <- factor(finalToPlot$variable, levels = c("Lead GWAS Signals Colocalized with caQTL Only","Lead GWAS Signals Colocalized with caQTL and eQTL","Lead GWAS Signals Colocalized with eQTL Only")) 
  
  p <- ggplot(finalToPlot, aes(x=group, y=value,fill=group)) + geom_boxplot() + ggtitle(paste0("GWAS Signals Explained by Global caQTLs and ",tissue," eQTLs"))
  p <- p + theme(legend.position="bottom") + theme(axis.title.x=element_blank(), axis.title.y=element_blank()) + theme(plot.title = element_text(hjust = 0.5),axis.text.x = element_text(angle = 45,hjust=1)) + theme(text=element_text(size=12))
  ggsave(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Figures/supplementary_gwas_explained_boxplot.singleTissue_eqtl.",tissue,".10.21.24.png"),p,height=12,width=12,dpi=1200,unit='in')
  
}





################################################################################################
#####Supplementary Figure 24 - Colocalizing caQTL/eQTL/GWAS locus SORT1 Positive Control########
################################################################################################

##modify functions to use
gg_genetracks <- function(loc,
                          filter_gene_name = NULL,
                          filter_gene_biotype = NULL,
                          border = FALSE,
                          cex.axis = 1,
                          cex.lab = 1,
                          cex.text = 0.7,
                          gene_col = ifelse(showExons, 'blue4', 'skyblue'),
                          exon_col = 'blue4',
                          exon_border = 'blue4',
                          showExons = TRUE,
                          maxrows = NULL,
                          text_pos = 'top',
                          xticks = TRUE,
                          xlab = NULL) {
  if (!inherits(loc, "locus")) stop("Object of class 'locus' required")
  g <- genetracks_grob(loc,
                       filter_gene_name,
                       filter_gene_biotype,
                       border,
                       cex.text,
                       gene_col,
                       exon_col,
                       exon_border,
                       showExons,
                       maxrows,
                       text_pos)
  if (is.null(xlab) & xticks) xlab <- paste("Chromosome", loc$seqname, "(Mb)")
  
  g2 <- ggplot(data.frame(x = NA),
               aes(xmin = loc$xrange[1] / 1e6, xmax = loc$xrange[2] / 1e6)) + 
    geom_vline(xintercept = peakMetadata_filt$Start/1e6, linetype="dotted", color = "orange", size=1.5) + 
    geom_vline(xintercept = peakMetadata_filt$End/1e6, linetype="dotted", color = "orange", size=1.5) + 
    annotate(geom="label", x=peakMetadata_filt$Start/1e6, y=1, label=peakMetadata_filt$Peak,color="orange") + 
    (if (!is.null(g)) gggrid::grid_panel(g)) + 
    xlab(xlab) +
    theme_classic() +
    theme(axis.text = element_text(colour = "black", size = 10 * cex.axis),
          axis.title = element_text(size = 10 * cex.lab),
          axis.line.y = element_blank(),
          axis.text.y = element_blank(),
          axis.title.y = element_blank(),
          axis.ticks.y = element_blank()) +
    #xlim(loc$xrange[1] / 1e6, loc$xrange[2] / 1e6)
    if (!xticks) {
      g2 <- g2 +
        theme(axis.line.x = element_blank(),
              axis.ticks.x = element_blank(),
              axis.text.x = element_blank())
    }
  g2 
}


ld_reflookup <- function(rsid, pop='EUR', opengwas_jwt=get_opengwas_jwt())
{
  res <- api_query('ld/reflookup',
                   query = list(
                     rsid = rsid,
                     pop = pop
                   ),
                   opengwas_jwt=opengwas_jwt
  ) %>% get_query_content()
  if(length(res) == 0)
  {
    res <- character(0)
  }
  return(res)
}


library(locuszoomr)
library(dplyr)
library(tidyr)
library(readr)
library(reshape)
library(data.table)
library(coloc)
library(qvalue)
library(GenomicRanges)
library(R.utils)
library(jjb)
library(stringr)
library(TwoSampleMR)
library(ieugwasr)
library(ggplot2)
library(EnsDb.Hsapiens.v86)
library(splitstackshape)


args = commandArgs(trailingOnly=TRUE)

#arguments read in as variables
multiTissue_peak = args[1]
tissue = args[2]
gene = args[3]
chrom = args[4]
pheno = args[5]
geneName = args[6]
print(geneName)

#read in key
key = fread("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/phenoKeyForFigures.txt",header=F)

#get pheno info
phenoInfo=key %>% dplyr::filter(V1==pheno)
keyTrait = as.character(phenoInfo$V2)

#read in peak metadata
peakMetadata <- read.table("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/inputFiles/cpm_peakInfo.txt",header=T)

#get metadata for peak of interest
peakMetadata_filt <- peakMetadata %>% dplyr::filter(Peak == multiTissue_peak )


#read in rsid file loop
all_idFile <- data.frame()
idFile <- fread(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/kaviar_af/Kaviar-160204-Public/vcfs/Kaviar-160204-Public-hg38-trim.noHead.vcf.chr",chrom,".vcf.gz"))
idFile$variant <- paste0(idFile$V1,"_",idFile$V2,"_",idFile$V4,"_",idFile$V5,"_b38")
all_idFile <- rbind(all_idFile,idFile)


#read in AF data loop
allMultiTissueAF <- data.frame()

multiTissueAF = read.table(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/tensorQTL/genotype/chr",chrom,".allFinalSamples.AF_filesForColocFinal.txt"),header=T)
multiTissueAF = within(multiTissueAF, INFO<-data.frame(do.call('rbind', strsplit(as.character(INFO), '=', fixed=TRUE))))
AF=as.character(multiTissueAF$INFO$X4)
multiTissueAF$MAF = as.numeric(AF)
multiTissueAF$match <- paste0(multiTissueAF$CHROM,":",multiTissueAF$POS)

allMultiTissueAF <- rbind(allMultiTissueAF,multiTissueAF)


#read in caqtl data
multiTissue_stats = fread(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/tensorQTL/prinComp_200/plink_maf_filter_test/tensorqtl_yuanAllSamples_4.10.24_prinComp200_allTests_allChr.cis_qtl_pairs.",chrom,".FDR5.peaks.txt"),header=T)
colnames(multiTissue_stats) = c('phenotype_id','variant_id','start_distance','end_distance','af','ma_samples','ma_count','pval_nominal','slope','slope_se')

#get peak of interest from caqtl data and modify
multiTissue_stats <- multiTissue_stats %>% dplyr::filter(phenotype_id==multiTissue_peak)
#multiTissue_stats$pos=multiTissueFinal$POS
multiTissue_stats$chrom=chrom
multiTissue_stats$rsid=multiTissue_stats$variant_id
multiTissue_stats$p=multiTissue_stats$pval_nominal

#add AF to caQTL stats
multiTissueFinal = merge(allMultiTissueAF, multiTissue_stats, by.x='ID', by.y='variant_id')
multiTissueFinal$variant <- paste0(multiTissueFinal$CHROM,"_",multiTissueFinal$POS,"_",multiTissueFinal$REF,"_",multiTissueFinal$ALT,"_b38")
multiTissueFinal$pos=multiTissueFinal$POS



#read in eqtl data
eqtl <- read.table(paste0("/project/voight_datasets_01/GTEx_v8/TissueSpecific/",tissue,".allpairs.txt.gz"),header=T)
eqtl <- eqtl %>% dplyr::filter(gene_id==gene)
eqtl$variant = gsub("chr","",eqtl$variant_id)

#merge eqtl and caqtl data
m = merge(eqtl, multiTissueFinal, by="variant")

#data check
print("m")
print(m)
print(nrow(m))


#read in gwas data

gwas = read_delim(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/chosenTraits_bw/",pheno,"/",pheno,"_hg38_chr",chrom,".txt.gz"),delim="\t",col_names=TRUE)
gwas$chr = gwas$seqnames


newVariant<-paste0(gwas$seqnames,":",gwas$start,":",gwas$major_allele,":",gwas$minor_allele)

newVariant<-as.data.frame(newVariant)
gwas<-cbind(gwas,newVariant)
gwas$pos=gwas$start

gwas$SNP = gsub(":","_",gwas$newVariant)
#gwas$EA = toupper(gwas$EA)
#gwas$NEA = toupper(gwas$NEA)
#gwas$SE = gwas$StdErr
#gwas$zScore_gwas = (gwas$Beta/gwas$StdErr)
gwas$variant = paste(gwas$SNP,"b38",sep="_")



#merge caqtl and gwas
z <- merge(gwas, multiTissueFinal, by="variant")

#filter z to keep only snps in LD reference panel - otherwise error is thrown
open_gwas_jwt="eyJhbGciOiJSUzI1NiIsImtpZCI6ImFwaS1qd3QiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJhcGkub3Blbmd3YXMuaW8iLCJhdWQiOiJhcGkub3Blbmd3YXMuaW8iLCJzdWIiOiJid2VuekB1cGVubi5lZHUiLCJpYXQiOjE3MTg3MjE3MzAsImV4cCI6MTcxOTkzMTMzMH0.O7Zan_Pw8Vf60D_KCqIiBGXIKSpmrvaJOA-KMl7F43TKQV4davB6BKUxYVisF_nzi2L3EgiOQwbuu18CYyRT29pfyc8Cp-OMppYr_1EGwPSKG4vep0iNPRVtueaoys2EI5pV0P15EhI1bTm7du-T11Eg8HJKZZI6EAxnb_xR6RvGpM_8LdNKOItA9XO2O6r3KSfMVFGpdz0SVgwk_-Ts6n_OIEzwHYIl7P-naCWFA3KySLmuSJPcXMxhMRvHlzyUQbWziX7TKqOxUv996HJNrnHSGB--FAuTvRNjsgyoqVOfAQoQlHmn-9gZ03u56uafqO2IKsL4JFU45a9ZTcA82A"
snpsToKeep <- ld_reflookup(z$rsid,opengwas_jwt=open_gwas_jwt)
z_final <- z %>% dplyr::filter(rsid %in% snpsToKeep)
print(head(z_final))

#get plotting objects

caqtl_loc <- locus(data = m, gene = geneName,ens_db = "EnsDb.Hsapiens.v86",chrom="chrom",pos="pos",labs="rsid",p="pval_nominal.y",flank = 1e5)
caqtl_loc <- link_LD(caqtl_loc, token = "e16894448bcb")

eqtl_loc <- locus(data = m, gene = geneName,ens_db = "EnsDb.Hsapiens.v86",chrom="chrom",pos="pos",labs="rsid",p="pval_nominal.x",flank = 1e5)
eqtl_loc <- link_LD(eqtl_loc, token = "e16894448bcb")

z_final$pos <- z_final$POS

gwas_loc <- locus(data = z_final, gene = geneName,ens_db = "EnsDb.Hsapiens.v86",chrom="chrom",pos="pos",labs="rsid",p="pval",flank = 1e5)
gwas_loc <- link_LD(gwas_loc, token = "e16894448bcb")


eqtlFinal = merge(all_idFile, eqtl, by='variant')

#get plot object
eqtl_overlay_loc <- locus(data = eqtlFinal, gene = geneName,ens_db = "EnsDb.Hsapiens.v86",chrom="V1",pos="V2",labs="V3",p="pval_nominal",flank = 1e5)
eqtl_overlay_loc <- link_LD(eqtl_overlay_loc, token = "e16894448bcb")

#loc2 <- link_eqtl(eqtl_overlay_loc, token = "e16894448bcb")


#all gwas plot
gwas$finalVar <- paste0("chr",gwas$variant)
gwasFinal = merge(all_idFile, gwas, by='variant')


gwasFinal_filt <- gwasFinal %>% dplyr::filter(pos > (peakMetadata_filt$Start-200000) & pos < (peakMetadata_filt$End+200000))

#get snps to keep for plot - otherwise lots of missing LD
allSnpsToKeep <- list()
for (i in seq(from=0,to=nrow(gwasFinal_filt),by=100)){ 
  i=i+100
  subset <- gwasFinal_filt[i:(i+100),]
  snpsToKeep <- ld_reflookup(subset$V3,opengwas_jwt=open_gwas_jwt)
  allSnpsToKeep <- append(allSnpsToKeep,snpsToKeep)
}


gwasFinal_final <- gwasFinal %>% dplyr::filter(V3 %in% allSnpsToKeep)

#create large GWAS window plotting object
all_gwas_loc <- locus(data = gwasFinal_final, gene = geneName,ens_db = "EnsDb.Hsapiens.v86",chrom="chr",pos="pos",labs="V3",p="pval",flank = 1e5)
all_gwas_loc <- link_LD(all_gwas_loc, token = "e16894448bcb")

#create panels to join together
library(cowplot)
p1 <- gg_scatter(caqtl_loc,size=3,cex.axis = 1.5,cex.lab = 1.5, pcutoff=F,labels = "index",nudge_x = 0.03, ylab=paste0("Coloc ",multiTissue_peak,"\n-log10( caQTL p value)")) +theme(axis.title.y=element_text(angle=0,vjust = 0.5))
p2 <- gg_scatter(eqtl_loc,size=3,cex.axis = 1.5,cex.lab = 1.5, pcutoff=F,labels = "index", nudge_x = 0.03,ylab=paste0("Coloc GTEx ",tissue," ",geneName, "\n-log10(eQTL p value)"))+theme(axis.title.y=element_text(angle=0,vjust = 0.5))
p5 <- gg_scatter(gwas_loc,size=3, cex.axis = 1.5,cex.lab = 1.5,pcutoff=F,labels = "index", nudge_x = 0.03,ylab=paste0("Coloc ",keyTrait,"\n -log10(GWAS p value)"))+theme(axis.title.y=element_text(angle=0,vjust = 0.5))
p3 <- gg_scatter(eqtl_overlay_loc,size=3, cex.axis = 1.5,cex.lab = 1.5,pcutoff=F,labels = "index", nudge_x = 0.03,ylab=paste0("GTEx ",tissue," ",geneName,"\n-log10(eQTL p value)"))+theme(axis.title.y=element_text(angle=0,vjust = 0.5))
p6 <- gg_scatter(all_gwas_loc,size=3,cex.axis = 1.5,cex.lab = 1.5,pcutoff=F, labels = "index", nudge_x = 0.03,ylab=paste0(keyTrait,"\n -log10(GWAS p value)"))+theme(axis.title.y=element_text(angle=0,vjust = 0.5))
p4 <- gg_genetracks(caqtl_loc,cex.lab=1.5,cex.axis = 1.5,cex.text=1.5) 

#plot and save
plot_grid(p1, p2, p5, p3, p6, p4, ncol = 1,align = "v")

ggsave(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/chosenTraits_bw/locusZoom_colocPlots/",multiTissue_peak,"_",tissue,"_",geneName,"_",keyTrait,".pdf"), width = 12, height = 18)


#submit with Rscript locusZoom_coloc_loopVersion.R peak_80195 Liver ENSG00000134243.11 1 20002_1473 SORT1





##############################################################################################
#####Supplementary Figure 25 - Peak 252469 Normalized ATAC-seq read counts by genotype########
##############################################################################################

#run in bash 
#plink --bfile /project/voight_viz/bwenz/multiTissue_caQTL_Mapping/tensorQTL/genotype/allSamples_maf_0.05_plink --extract var.txt --recode --out rs7589901


#R
x<-read.table("test.ped")

#create genotype column
x$GT<-paste0(x$V7,x$V8)

#extract only sample and gt columns
final <- data.frame(x$V2,x$GT)
colnames(final) <- c("Sample","Genotype")

#write.table
write.table(final,"/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Figures/Fig5/sample_rs7589901_genotypes.txt",col.names=T,row.names=F,quote=F,sep='\t')



#extract norm counts for this peak - peak_252469
library(data.table)
library(dplyr)

x <- fread("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/tensorQTL/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.noBL.txt.QTLsorted.txt.BW.norm.txt.bed.gz",header=T)

filtered <- x %>% dplyr::filter(ID == "peak_252469")
write.table(filtered,"peak_252469_counts.txt",col.names=T,row.names=F,quote=F,sep='\t')



#caqtl plot
library(dplyr)
library(ggplot2)
library(tidyr)
library(data.table)

counts <- fread("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Figures/Fig5/peak_252469_counts.txt")
countsOnly <- counts[,5:1458]
countsOnlyDF <- data.frame(colnames(countsOnly),t(countsOnly))
rownames(countsOnlyDF) <- NULL
colnames(countsOnlyDF) <- c("Sample","Counts")

genotypes<-fread("sample_rs7589901_genotypes.txt")

merged <- merge(countsOnlyDF,genotypes,by="Sample")

p=ggplot(merged, aes(x=Genotype, y=Counts, color=Genotype)) +
  geom_boxplot() +
  geom_jitter(height=0, width=0.05,size=4) +
  theme_bw() +
  ggtitle("Peak 252469 Accessibility\n by rs7589901 Genotype")+
  theme(legend.position = "none" ,plot.title = element_text( size=28, face="bold.italic"), axis.title.x = element_text(size=28),axis.title.y = element_text( size=28), axis.text.x = element_text( size=28),axis.text.y = element_text( size=28),panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(),) + scale_colour_manual(values = c("#b58900", "#cb4b16", "#dc322f"))

ggsave("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Figures/Fig5/rs7589901_caQTLplot.png",p)




###########################################################################################################
#####Supplementary Figure 25 - Peak 252469 Normalized ATAC-seq read counts by genotype by cell type########
###########################################################################################################


#caqtl plot
library(dplyr)
library(ggplot2)
library(tidyr)
library(data.table)

counts <- fread("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Figures/Fig5/peakCounts/peak_252469_counts.txt")
countsOnly <- counts[,5:1458]
countsOnlyDF <- data.frame(colnames(countsOnly),t(countsOnly))
rownames(countsOnlyDF) <- NULL
colnames(countsOnlyDF) <- c("Sample","Counts")

genotypes<-fread("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Figures/Fig5/sample_rs7589901_genotypes.txt")

merged <- merge(countsOnlyDF,genotypes,by="Sample")

#add metadata
#read in metadata
metadata <- fread("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.clusterAnalyses/uniqueDonors_metadata.txt")

#get only sample id and tissue
metadata_sub <- data.frame(metadata$run_accession,metadata$Combined_Tissue_Cell_Type)

#add metadata to Counts by genotype
merged_meta <- merge(merged,metadata_sub,by.x="Sample",by.y="metadata.run_accession")

p=ggplot(merged_meta, aes(x=Genotype, y=Counts, color=Genotype)) +
  geom_boxplot() +
  geom_jitter(height=0, width=0.05,size=1) +
  theme_bw() +
  ggtitle("Peak 252469 Accessibility\n by rs7589901 Genotype")+
  theme(legend.position = "none" ,plot.title = element_text( size=12, face="bold.italic"), axis.title.x = element_text(size=12),axis.title.y = element_text( size=12), axis.text.x = element_text( size=12),axis.text.y = element_text( size=12),panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(),) + scale_colour_manual(values = c("#b58900", "#cb4b16", "#dc322f")) +
  facet_wrap(~metadata.Combined_Tissue_Cell_Type)

ggsave("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/manuscript_review_analyses/caQTL_genotype_plots_by_cellType/rs7589901_caQTLplot.byTissue.png",p,height=15,width=15,units="in")





#################################################################################
#####Supplementary Figure 29 - Cluster samples biological origin barplots########
#################################################################################

#plot all cluster barplots
#load packages
library(data.table)
library(ggplot2)
library(dplyr)
library(tidyverse)
library(gridExtra)
library(scales)

numClusters=11

plot_list <- list() 

for (i in (1:numClusters)){
  #read in data
  metadata <- fread(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.clusterAnalyses/11_1_24_analyses/cluster",i,".metadata.txt"),header=F,sep='\t')
  colnames(metadata) <- c("study_accession","sample_accession","experiment_accession","run_accession","tax_id","scientific_name","base_count","read_count","study_title","fastq_ftp","submitted_ftp","sra_ftp","sample_title","Tissue_Cell_Type","Combined_Tissue_Cell_Type","Cancer","Cell_Line","Primary_Tissue","Differentiated","Abstract","projNum")
  
  
  
  
  
  plot_list[[i]] <- metadata %>% group_by(Combined_Tissue_Cell_Type) %>% count %>% arrange(desc(n)) %>% ggplot(aes(x = reorder(Combined_Tissue_Cell_Type, n), y = n)) + geom_bar(stat = "identity",color="darkblue", fill="lightblue") + ggtitle(paste0("Cluster ", i, " Samples")) + theme(axis.title.y=element_blank(),text=element_text(size=7),axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + xlab("Tissue/Cell") + ylab("Count") +  coord_flip()
  
  p <- metadata %>% group_by(Combined_Tissue_Cell_Type) %>% count %>% arrange(desc(n)) %>% ggplot(aes(x = reorder(Combined_Tissue_Cell_Type, n), y = n)) + geom_bar(stat = "identity",color="darkblue", fill="lightblue") + ggtitle(paste0("Cluster ", i, " Samples")) + theme(axis.title.y=element_blank(),text=element_text(size=14),axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + xlab("Tissue/Cell") + ylab("Count") +  coord_flip()
  ggsave(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.clusterAnalyses/11_1_24_analyses/cluster",i,".metadata.barplot.png"),p)
}

final <- grid.arrange(grobs=plot_list,ncol=3)
ggsave(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.clusterAnalyses/11_1_24_analyses/allCluster_metadataPlots_singleFig.png"),final,height=11,width=8.5,units = "in")





####################################################################################################
#####Supplementary Figure 30 - Proportion of each cluster in each biological source category########
####################################################################################################

#plot all cluster barplots
#load packages
library(data.table)
library(ggplot2)
library(dplyr)
library(tidyverse)

numClusters=11

allMetadata <- data.frame()
for (i in (1:numClusters)){
  #read in data
  metadata <- fread(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.clusterAnalyses/11_1_24_analyses/cluster",i,".metadata.txt"),header=F,sep='\t')
  colnames(metadata) <- c("study_accession","sample_accession","experiment_accession","run_accession","tax_id","scientific_name","base_count","read_count","study_title","fastq_ftp","submitted_ftp","sra_ftp","sample_title","Tissue_Cell_Type","Combined_Tissue_Cell_Type","Cancer","Cell_Line","Primary_Tissue","Differentiated","Abstract","projNum")
  metadata$cluster <- i
  
  allMetadata <- rbind(allMetadata,metadata)
}



p <- allMetadata %>% group_by(Combined_Tissue_Cell_Type) %>% count %>% arrange(desc(n)) %>% ggplot(aes(x = reorder(Combined_Tissue_Cell_Type, n), y = n)) + geom_bar(stat = "identity",color="darkblue", fill="lightblue") + theme(text=element_text(size=16),axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + xlab("Tissue/Cell") + ylab("Count") +  coord_flip() 


#all in same plot with common axis
p <- allMetadata %>% group_by(Combined_Tissue_Cell_Type,cluster) %>% count %>% arrange(desc(n)) %>% ggplot(aes(x = reorder(Combined_Tissue_Cell_Type, n), y = n)) + geom_bar(stat = "identity",color="darkblue", fill="lightblue") + theme(text=element_text(size=5.5),axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + xlab("Tissue/Cell") + ylab("Count") +  coord_flip() 
p <- p + facet_wrap(vars(cluster))

ggsave(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.clusterAnalyses/11_1_24_analyses/all.cluster.metadata.barplot.png"),p,height=12,width=12)





######################################################################################
#####Supplementary Figure 31 - Color clustering results by metadata categories########
######################################################################################

library(data.table)
library(ggplot2)
library(dplyr)
library(tidyverse)

#read in data
metadata <- fread("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Analyses/peakCallingMetadata_final.txt",header=T)
colnames(metadata) <- gsub(" ","_",colnames(metadata))
colnames(metadata) <- gsub("/","_",colnames(metadata))

#subset metadata to color
metadata_subset <- data.frame(metadata$run_accession,metadata$Combined_Tissue_Cell_Type,metadata$Cancer,metadata$Cell_Line,metadata$Primary_Tissue,metadata$Differentiated)


dp_plot <- fread("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.clusterAnalyses/clusters_reorganized_11.5.24.txt")
dp_plot_final <- merge(dp_plot,metadata_subset,by.x="samples",by.y="metadata.run_accession") 
dp_plot_final <- as.data.frame(dp_plot_final)
colnames(dp_plot_final) <- gsub("metadata.","",colnames(dp_plot_final))


#this wont work - colors wont show
for (i in colnames(dp_plot_final[,4:9])){
  
  g = ggplot(data = dp_plot_final) +
    geom_point(aes(x = X1, y = X2, color = paste(i)))  +
    theme_bw() +
    ggtitle("") +
    xlab('UMAP 1') +
    ylab('UMAP 2')
  
  ggsave(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.clusterAnalyses/11_1_24_analyses/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.singleSample.meanScaled.clusters.allPeaks.noOutliers.colored.",i,".2.1.24.png"),g, height = 12, width = 10)
}


#manual
g = ggplot(data = dp_plot_final) +
  geom_point(aes(x = X1, y = X2, color = Combined_Tissue_Cell_Type))  +
  theme_bw() +
  ggtitle("") +
  xlab('UMAP 1') +
  ylab('UMAP 2')

i="Combined_Tissue_Cell_Type"
ggsave(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.clusterAnalyses/11_1_24_analyses/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.singleSample.meanScaled.clusters.allPeaks.noOutliers.colored.",i,".2.1.24.png"),g, height = 12, width = 10)



g = ggplot(data = dp_plot_final) +
  geom_point(aes(x = X1, y = X2, color = Cancer))  +
  theme_bw() +
  ggtitle("") +
  xlab('UMAP 1') +
  ylab('UMAP 2')

i="Cancer"
ggsave(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.clusterAnalyses/11_1_24_analyses/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.singleSample.meanScaled.clusters.allPeaks.noOutliers.colored.",i,".2.1.24.png"),g, height = 12, width = 10)




g = ggplot(data = dp_plot_final) +
  geom_point(aes(x = X1, y = X2, color = Cell_Line))  +
  theme_bw() +
  ggtitle("") +
  xlab('UMAP 1') +
  ylab('UMAP 2')

i="Cell_Line"
ggsave(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.clusterAnalyses/11_1_24_analyses/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.singleSample.meanScaled.clusters.allPeaks.noOutliers.colored.",i,".2.1.24.png"),g, height = 12, width = 10)



g = ggplot(data = dp_plot_final) +
  geom_point(aes(x = X1, y = X2, color = Primary_Tissue))  +
  theme_bw() +
  ggtitle("") +
  xlab('UMAP 1') +
  ylab('UMAP 2')

i="Primary_Tissue"
ggsave(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.clusterAnalyses/11_1_24_analyses/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.singleSample.meanScaled.clusters.allPeaks.noOutliers.colored.",i,".2.1.24.png"),g, height = 12, width = 10)



g = ggplot(data = dp_plot_final) +
  geom_point(aes(x = X1, y = X2, color = Differentiated))  +
  theme_bw() +
  ggtitle("") +
  xlab('UMAP 1') +
  ylab('UMAP 2')

i="Differentiated"
ggsave(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.clusterAnalyses/11_1_24_analyses/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.singleSample.meanScaled.clusters.allPeaks.noOutliers.colored.",i,".2.1.24.png"),g, height = 12, width = 10)





######################################################################################
#####Supplementary Figure 32 - Cluster caQTL peak genome annotation enrichments#######
######################################################################################

library(data.table)
library(dplyr)
library(annotatr)
library(stringr)

library(reshape)
library(ggplot2)

allClusterDF <- data.frame()

for (i in (1:11)){
  
  
  finalDF <- fread(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.clusterAnalyses/11_1_24_analyses/filteredPeakAnalyses_0.5/cluster",i,"/cluster",i,"_caQTL_peakAnnotations.realRegions_vs_random_100iterations.stats.10.28.24.txt"))
  colnames(finalDF) <- gsub(paste0("Cluster",i,"_caQTLs"),"cluster_caQTLs",colnames(finalDF))

  finalDF <- finalDF %>% dplyr::filter(pval_enriched <= 0.05 | pval_depleted <= 0.05)
  
  finalDF$cluster <- i
  
  if (i==1){
    allClusterDF <- finalDF
  }else{  
    allClusterDF <- rbind(allClusterDF,finalDF)
  }
  
}

allClusterDF <- as.data.frame(allClusterDF)
allClusterDF$Annotation <- gsub("_"," ",allClusterDF$Annotation)

#plot

p=ggplot(allClusterDF,aes(x=Annotation,y=Enrichment,fill=as.factor(cluster))) +  geom_bar(stat="identity",position="dodge") + ylab("Enrichment (Fold change)")+ theme_bw() + theme(axis.text.x = element_text(angle = 45, hjust=1)) + theme(legend.title = element_text(size = 16),legend.text = element_text(size = 14))+theme(plot.margin = margin(1,1,1.5,5, "cm")) + theme(text=element_text(size=22)) + guides(fill=guide_legend(title="Cluster")) + ggtitle("Cluster caQTLs Genome Annotation Enrichments") +  ggeasy::easy_center_title()

ggsave(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.clusterAnalyses/11_1_24_analyses/filteredPeakAnalyses_0.5/allClusters_GenomeAnnotations_enrichment_vsRandom.10.28.24.png"),p,width=10,height=10,dpi=1200)





#############################################################################################
#####Supplementary Figure 33 - Cluster caQTL lead variant enrichment within caQTL peak#######
#############################################################################################

library(data.table)
library(ggplot2)
library(dplyr)
library(tidyverse)
library(gridExtra)
library(scales)
library(mlr3misc)

optimized_file <- fread("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.clusterAnalyses/11_clusters_analyses/filteredPeakAnalyses_0.5/pc_optimization_final.txt",header=T)

plot_list <- list() 

for (cluster in (1:11)){
  
  clusterRow <- optimized_file %>% dplyr::filter(Cluster == cluster)
  prinComp <- clusterRow$PCs
  
  cluster_peakMetadata <- fread(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.clusterAnalyses/11_clusters_analyses/filteredPeakAnalyses_0.5/cluster",cluster,"/cluster",cluster,"_CPM_average_noBL.withPeakInfo.txt.QTLsorted.txt.metadata"),header=T)
  cluster_qtls <- fread(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.clusterAnalyses/11_clusters_analyses/filteredPeakAnalyses_0.5/cluster",cluster,"/cluster",cluster,"_fdr5_caqtls.txt"),header=T)
  
  qtls_withMetadata <- merge(cluster_qtls,cluster_peakMetadata,by.x="phenotype_id",by.y="Peak")
  
  allLead <- data.frame()
  for (chr in (1:22)){
    
    clusterStats <- fread(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.clusterAnalyses/11_clusters_analyses/filteredPeakAnalyses_0.5/cluster",cluster,"/prinComp_",prinComp,"/tensorqtl_cluster",cluster,"_prinComp",prinComp,"_4.3.24_allTests_allChr.cis_qtl_pairs.",chr,".txt"))
    
    qtls_withMetadata_chr <- qtls_withMetadata %>% dplyr::filter(Chr == chr)
    
    for (peak in qtls_withMetadata_chr$phenotype_id){
      clusterStats_peak <- clusterStats %>% dplyr::filter(phenotype_id == peak)
      clusterStats_peak_lead <- clusterStats_peak %>% slice(which_min(pval_nominal,ties_method = "random"))
      allLead <- rbind(allLead,clusterStats_peak_lead)
    }
    
  }
  
  #write new qtls to file
  write.table(allLead,paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.clusterAnalyses/11_clusters_analyses/filteredPeakAnalyses_0.5/cluster",cluster,"/cluster",cluster,"_leadQTLs_fixed_toRandom.6.13.24.txt"),col.names=T,row.names=F,quote=F,sep='\t')
  
  cluster_qtls <- allLead
  
  qtls_withMetadata <- merge(cluster_qtls,cluster_peakMetadata,by.x="phenotype_id",by.y="Peak")
  
  qtls_withMetadata$snpPos <- qtls_withMetadata$Start + qtls_withMetadata$start_distance + 1
  
  qtls_withMetadata$peakLength <- qtls_withMetadata$End - qtls_withMetadata$Start
  
  qtls_withMetadata$peakMidpoint <- qtls_withMetadata$Start + (qtls_withMetadata$peakLength/2)
  
  qtls_withMetadata$leadVar_dist_to_peakMid <- qtls_withMetadata$peakMidpoint-qtls_withMetadata$snpPos
  
  qtls_withMetadata <- as.data.frame(qtls_withMetadata)
  
  plot_list[[cluster]] <- qtls_withMetadata %>% ggplot(aes(x=leadVar_dist_to_peakMid))+ geom_histogram(color="darkblue", fill="lightblue",bins=50) + xlim(-15000,15000) + xlab("Distance to Peak Midpoint (bp)") + ylab("Counts") + theme_bw() + theme(text=element_text(size=8)) + ggtitle(paste0("Cluster ",cluster," Lead caQTL Enrichment \n Within Peak"))
  
}

final <- grid.arrange(grobs=plot_list,ncol=3)
ggsave(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.clusterAnalyses/11_clusters_analyses/filteredPeakAnalyses_0.5/allCluster_lead_variant_enrichment_inPeak_fixedLeadQTLs.png"),final,height=11,width=8.5,units = "in")





#########################################################################################
#####Supplementary Figure 34 - Cluster lead caQTL p values for global caQTL peaks #######
#########################################################################################

library(data.table)
library(ggplot2)
library(dplyr)
library(tidyverse)
library(gridExtra)
library(scales)
library(mlr3misc)
library(qvalue)

optimized_file <- fread("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.clusterAnalyses/11_clusters_analyses/filteredPeakAnalyses_0.5/pc_optimization_final.txt",header=T)

#read in aggregate data
lead_caqtls <- read.table("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/tensorQTL/prinComp_200/plink_maf_filter_test/tensorqtl_yuanAllSamples_4.10.24_prinComp200_allChr.cis_qtl.FDR5only.txt",header=T)

plot_list <- list() 

allCluster_globalReplication <- data.frame()

for (cluster in (1:11)){
  
  clusterRow <- optimized_file %>% dplyr::filter(Cluster == cluster)
  prinComp <- clusterRow$PCs
  
  cluster_qtls <- fread(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.clusterAnalyses/11_clusters_analyses/filteredPeakAnalyses_0.5/cluster",cluster,"/prinComp_",prinComp,"/tensorqtl_cluster",cluster,"_prinComp",prinComp,"_allChr_4.3.24.cis_qtl.txt.gz"),header=T)
  
  
  aggregate_cluster_overlap <- cluster_qtls %>% dplyr::filter(phenotype_id %in% lead_caqtls$phenotype_id)
  aggregate_cluster_overlap <- as.data.frame(aggregate_cluster_overlap)
  
  #get pi1
  all_pi1 <- data.frame()
  for (i in seq(from=0.1,to=0.9,by=0.05)){
    pi1 =  1 - qvalue_truncp(aggregate_cluster_overlap$pval_nominal,lambda = i)$pi0
    all_pi1 <- rbind(all_pi1,pi1)
  }
  
  print(all_pi1)
  
  colnames(all_pi1) <- c("All")
  median <- median(all_pi1$All)
  medianDF <- data.frame(cluster,median)
  allCluster_globalReplication <- rbind(allCluster_globalReplication,medianDF)
  
  plot_list[[cluster]] <- aggregate_cluster_overlap %>% ggplot(aes(x=pval_nominal))+ geom_histogram(color="darkblue", fill="lightblue",bins=20) + xlab("Nominal P value") + ylab("Counts") + theme_bw() + theme(text=element_text(size=8)) + ggtitle(paste0("Cluster ",cluster," Global caQTL Replication"))
  
  
}

final <- grid.arrange(grobs=plot_list,ncol=3)
ggsave(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.clusterAnalyses/11_clusters_analyses/filteredPeakAnalyses_0.5/allCluster_global_caqtl_replication.png"),final,height=11,width=8.5,units = "in")

#write to file
write.table(allCluster_globalReplication,"/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.clusterAnalyses/11_clusters_analyses/filteredPeakAnalyses_0.5/allClusters_globalReplication_medianpi1_acrossLambdaValues.txt",col.names=T,row.names=F,sep='\t',quote=F)





#################################################################################
#####Supplementary Figure 35 -  Sharing of caQTL peaks across each cluster#######
#################################################################################

library(stats)
library(pheatmap)
library(stats)
library(tidyverse)
#library(subset)
library(reshape2)
library(grid)
library(formattable)
library(reactablefmtr)


#save function
save_pheatmap_pdf <- function(x, filename, width=10, height=10) {
  stopifnot(!missing(x))
  stopifnot(!missing(filename))
  pdf(filename, width=width, height=height)
  setHook("grid.newpage", function() pushViewport(viewport(x=1.5,y=1.5,width=0.9, height=0.9, name="vp", just=c("right","top"))), action="prepend")
  grid::grid.draw(x$gtable)
  setHook("grid.newpage", NULL, "replace")
  grid.text("Comparison Cluster", y=0.001, gp=gpar(fontsize=16))
  grid.text("Reference Cluster", x=0.001, rot=90, gp=gpar(fontsize=16))
  dev.off()
}

#read in data and modify
x<-read.table("cluster_cluster_bulk_qtlPeak_overlap.10.25.24.txt",header=T)
subset <- data.frame(x$ReferenceCluster,x$ComparisonCluster,x$Percent_Ref_Replicated,x$Percent_Comp_Replicated)
colnames(subset) <- c("ReferenceCluster","ComparisonCluster","Percent_Ref_Replicated","Percent_Comp_Replicated")


#plot table
tableSubset<-data.frame(x$ReferenceCluster,x$NumRefQTLs,x$Percent_Ref_Replicated_in_Bulk)
colnames(tableSubset) <- c("Cluster","FDR5_caQTLs","Percent_Cluster_caQTLs_Replicated_in_Bulk")

table1 <- reactable(tableSubset,columns = list(Cluster = colDef(cell = data_bars(tableSubset, fill_by = "Percent_Cluster_caQTLs_Replicated_in_Bulk", text_position = "above"))))
save_reactable(table1, "table.html")

## set up storage matrix
# get names for row and columns
nameVals <- sort(unique(unlist(subset[1:2])))
# construct 0 matrix of correct dimensions with row and column names
myMat <- matrix(0, length(nameVals), length(nameVals), dimnames = list(nameVals, nameVals))

# fill in the matrix with matrix indexing on row and column names
myMat[as.matrix(subset[c("ReferenceCluster", "ComparisonCluster")])] <- subset[["Percent_Ref_Replicated"]]

#plot - no clustering
pheatmap(myMat,fontsize = 18,cluster_rows=F,cluster_cols=F,file="/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.clusterAnalyses/11_1_24_analyses/filteredPeakAnalyses_0.5/cluster_cluster_replication_noClustering.png")





###############################################################################
#####Supplementary Figure 36 -  Cluster 9 enrichment in external dataset#######
###############################################################################

#get gaffney LCL data replication
library(data.table)
library(ggplot2)

#read in gaffney data
gaffney <- fread("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Analyses/High_Resolution_Genetic_Mapping_Gaffney_LCL/lead_caQTL_variants.tsv.gz")

#read in cluster results
cluster <- fread("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.clusterAnalyses/11_1_24_analyses/filteredPeakAnalyses_0.5/cluster9/cluster9_fdr5_caqtls.10.25.24.txt")

#get overlapping snps
overlap <- merge(cluster,gaffney,by.x="variant_id",by.y="RsID")

#plot posterior probabilities
ggplot(overlap, aes(x=P_Lead))+ geom_histogram(color="darkblue", fill="lightblue",breaks = seq(0,1,0.05)) + xlab("Replication Posterior probability of the variant being the causal caQTL \n given that the peak is a caQTL") + ylab("Counts")
ggsave("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.clusterAnalyses/11_1_24_analyses/filteredPeakAnalyses_0.5/gaffney_cluster9_P_lead_plot.10.25.24.png")





####################################################################################
#####Supplementary Figure 37 -  Cluster colocalizing caQTL/eQTL eGene Sharing#######
####################################################################################

library(stats)
library(pheatmap)
library(stats)
library(tidyverse)
#library(subset)
library(reshape2)
library(grid)
library(formattable)
library(reactablefmtr)
library(data.table)

#all cluster coloc genes
allColoc <- fread("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.clusterAnalyses/11_1_24_analyses/filteredPeakAnalyses_0.5/eQTL_coloc/all_clusters_tissues_colocalizingGenes.txt")

allReplicationDF <- data.frame()
for (x in (1:11)){
  clusterGenes <- allColoc %>% dplyr::filter(cluster == x)
  for (z in (1:11)){
    compCluster <- allColoc %>% dplyr::filter(cluster == z)
    percent_rep <- length(intersect(clusterGenes$colocFinal.eGene,compCluster$colocFinal.eGene))/nrow(clusterGenes)
    
    repDF <- data.frame(x,z,nrow(clusterGenes),percent_rep)
    allReplicationDF <- rbind(allReplicationDF,repDF)
    
  }
}

colnames(allReplicationDF) <- c("Reference_Cluster","Comparison_Cluster","Number_Reference_Coloc_Genes","Percent_Replicating_eGenes")
write.table(allReplicationDF,"cluster_cluster_eGene_coloc_replication.txt",col.names=T,row.names=F,quote=F,sep='\t')

#change cluster 11 to 10 for matrix formation
#allReplicationDF$Reference_Cluster <- gsub("11","10",allReplicationDF$Reference_Cluster)
#allReplicationDF$Comparison_Cluster <- gsub("11","10",allReplicationDF$Comparison_Cluster)


## set up storage matrix
# get names for row and columns
nameVals <- sort(as.numeric(unique(unlist(allReplicationDF[1:2]))))
# construct 0 matrix of correct dimensions with row and column names
myMat <- matrix(0, length(nameVals), length(nameVals), dimnames = list(nameVals, nameVals))

# fill in the matrix with matrix indexing on row and column names
myMat[as.matrix(allReplicationDF[c("Reference_Cluster", "Comparison_Cluster")])] <- allReplicationDF[["Percent_Replicating_eGenes"]]

#change 10 back to 11
#colnames(myMat)<-gsub("10","11",colnames(myMat))
#rownames(myMat)<-gsub("10","11",rownames(myMat))

#plot - no clustering
pheatmap(myMat,cluster_rows=F,cluster_cols=F,file="/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.clusterAnalyses/11_1_24_analyses/filteredPeakAnalyses_0.5/eQTL_coloc/cluster_cluster_colocalizing_eGene_replication_noClustering.png")





################################################################################################
#####Supplementary Figure 38 -  eQTL/GWAS/global and cluster caQTL colocalization summary#######
################################################################################################

library(data.table)
library(dplyr)
library(tidyverse)

#read in data
##GWAS key

key = read.table("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/phenoKey.txt")


#gtex tissue list
tissueList <- fread("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/eqtl_gwas_coloc/eQTL_GWAS_coloc/gtexTissueList.txt",header=F)

#define variables
clump_par = 0.01

#get all eqtl coloc results

allPhenoTissue <- data.frame()
allClusterDF <- data.frame()
for (pheno in key$V1){
  
  #get variables
  phenoInfo=key %>% filter(V1==pheno)
  keyTrait = as.character(phenoInfo$V2)
  
  allTissueDF <- data.frame() 
  for (tissue in tissueList$V1){
    
    #read in file
    if (file.exists(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/caqtl_eqtl_coloc/newGTF/eQTL_GWAS/",pheno,"_",tissue,"_all_chr.eQTL_coloc.pruned.",clump_par,".newGTF.8.21.24.old_new.filtered.txt"))){
      if (file.info(paste0(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/caqtl_eqtl_coloc/newGTF/eQTL_GWAS/",pheno,"_",tissue,"_all_chr.eQTL_coloc.pruned.",clump_par,".newGTF.8.21.24.old_new.filtered.txt")))$size > 1){
        colocFinal <- fread(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/caqtl_eqtl_coloc/newGTF/eQTL_GWAS/",pheno,"_",tissue,"_all_chr.eQTL_coloc.pruned.",clump_par,".newGTF.8.21.24.old_new.filtered.txt"),header=T)
        allTissueDF <- rbind(allTissueDF,colocFinal)
      }else{
        print("no colocs")
      }
    }
  }
  
  
  #remove chr from lead gwas
  allTissueDF$leadGwasVariant <- gsub("chr","",allTissueDF$leadGwasVariant)
  
  
  
  
  #read in bulk caqtls
  if (file.exists(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/chosenTraits_bw/",pheno,"_colocResults/",keyTrait,"_",pheno,"_multiTissue_allPeaks_coloc.pruned.",clump_par,"_allColocResults.Final.filtered.withStats.10.19.24.txt"))){
    bulk_caQTL_colocs <- fread(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/multiTissue_caQTL_coloc/brandon_liver_multiTissue_coloc/battleLabGWAS/highly_heritable_traits_2/chosenTraits_bw/",pheno,"_colocResults/",keyTrait,"_",pheno,"_multiTissue_allPeaks_coloc.pruned.",clump_par,"_allColocResults.Final.filtered.withStats.10.19.24.txt"))
    
    #create df for bulk and cluster
    allClusters_bulk_df <- bulk_caQTL_colocs
    for (cluster in (1:11)){
      if (file.exists(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.clusterAnalyses/11_clusters_analyses/filteredPeakAnalyses_0.5/gwas_coloc/cluster",cluster,"/",pheno,"_colocResults/",keyTrait,"_",pheno,"_multiTissue_allPeaks_coloc.pruned.",clump_par,"_cluster",cluster,".10.26.24_allColocResults.Final.filtered.withStats.txt"))){
        x <- fread(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.clusterAnalyses/11_clusters_analyses/filteredPeakAnalyses_0.5/gwas_coloc/cluster",cluster,"/",pheno,"_colocResults/",keyTrait,"_",pheno,"_multiTissue_allPeaks_coloc.pruned.",clump_par,"_cluster",cluster,".10.26.24_allColocResults.Final.filtered.withStats.txt"))
        allClusters_bulk_df <- rbind(allClusters_bulk_df,x)
        
      }
    }
  }
  
  #get overlap
  overlap <- intersect(allClusters_bulk_df$gwas_lead,allTissueDF$leadGwasVariant)
  
  #get caqtl and eqtl specific lead gwas variant colocs
  caqtl_specific <- setdiff(allClusters_bulk_df$gwas_lead,allTissueDF$leadGwasVariant)
  eqtl_specific <- setdiff(allTissueDF$leadGwasVariant,allClusters_bulk_df$gwas_lead)
  
  #get data frame for caQTL only gwas colocalization
  caQTL_only_df <- allClusters_bulk_df %>% dplyr::filter(gwas_lead %in% caqtl_specific)
  
  
  
  clusterDF <- data.frame(keyTrait,length(overlap),length(caqtl_specific),nrow(allClusters_bulk_df),length(eqtl_specific),nrow(allTissueDF))
  colnames(clusterDF) <- c("Pheno","Lead GWAS Variants Colocalize with caQTL and eQTL","Lead GWAS Variants Colocalize with caQTL Only","Total Number of caQTL/GWAS Colocalizations","Lead GWAS Variants Colocalize with eQTL Only","Total Number of eQTL/GWAS Colocalizations")
  
  clusterDF <- na.omit(clusterDF)
  
  allPhenoTissue <- rbind(allPhenoTissue,clusterDF)
  
  
  
}


stats<-allPhenoTissue
stats <- unique(stats)

#write to file
write.table(stats,"/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.clusterAnalyses/11_clusters_analyses/filteredPeakAnalyses_0.5/gwas_coloc/allPheno_allTissue_gwas_eqtl_bulk_cluster_caqtl_colocStats.10.26.24.txt",row.names=F,col.names=T,quote=F,sep='\t')

colnames(stats) <- gsub(" ","_",colnames(stats))
colnames(stats) <- gsub("/","_",colnames(stats))
stats <- as.data.frame(stats)

#modify analysis column values
stats$Pheno <- gsub("Non_cancer_illness_code_","",stats$Pheno)
stats$Pheno <- gsub("Blood_clot_DVT_bronchitis_emphysema_asthma_rhinitis_eczema_allergy_diagnosed_by_doctor_","",stats$Pheno)
stats$Pheno <- gsub("Vascular_heart_problems_diagnosed_by_doctor_","",stats$Pheno)
stats$Pheno <- gsub("_"," ",stats$Pheno)
stats$Pheno <- str_to_title(stats$Pheno)
stats$Pheno <- gsub("Neutrophill","Neutrophil",stats$Pheno)
stats$Pheno <- gsub("Eosinophill","Eosinophil",stats$Pheno)

#subset analysis - all stats
stats_subset <- data.frame(stats$Pheno,stats$Total_Number_of_caQTL_GWAS_Colocalizations,stats$Total_Number_of_eQTL_GWAS_Colocalizations)
colnames(stats_subset) <-  gsub("stats.","",colnames(stats_subset))
colnames(stats_subset) <- gsub("_"," ",colnames(stats_subset))


p <- stats_subset %>% mutate(Label = Pheno) %>% reshape2::melt(.) %>% ggplot(., aes(x = reorder(Label, -value), y = value, fill = variable)) + geom_bar(stat='identity')
p <- p + theme(axis.text.x = element_text(angle = 45, hjust=1,size=7),plot.margin = margin(10, 100, 10, 30)) + labs(title = paste0("GWAS eQTL All Tissue and GWAS/caQTL Aggregate/Cluster Colocalization Stats")) + xlab("Trait") + ylab("Count")


ggsave(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Figures/Fig4_supplemental_gwas_all_eqtl_tissues_caqtl_bulk_and_cluster_stats_allRuns_stackedBarplot.0.01.noBL.10.26.24.png"),p, height=8, width=15, unit ="in")


#get subset oriented on variants
stats_subset_var <- data.frame(stats$Pheno,stats$Lead_GWAS_Variants_Colocalize_with_caQTL_Only,stats$Lead_GWAS_Variants_Colocalize_with_caQTL_and_eQTL,stats$Lead_GWAS_Variants_Colocalize_with_eQTL_Only)
colnames(stats_subset_var) <-  gsub("stats.","",colnames(stats_subset_var))

#change column names to remove spaces
colnames(stats_subset_var) <- gsub("_"," ",colnames(stats_subset_var))

#get sum of gwas lead variants that colocalize
for (z in 1:nrow(stats_subset_var)){
  stats_subset_var$sum[z] <- sum(stats_subset_var[z,2:4])
}

#filter out traits with fewer colocalizations

stats_subset_var_filt <- stats_subset_var %>% dplyr::filter(!sum < 50)
stats_subset_var_final <- stats_subset_var_filt[,1:4]
stats_subset_var_final$Pheno <- make.unique(stats_subset_var_final$Pheno)

p <- stats_subset_var_final %>% mutate(Label = Pheno) %>% reshape2::melt(.) %>% ggplot(., aes(x = reorder(Label, -value), y = value, fill = variable)) + geom_bar(stat='identity')
p <- p + theme(text=element_text(size=26)) + theme(axis.text.x = element_text(angle = 45, hjust=1,size=8),plot.margin = margin(10, 100, 10, 30)) + labs(title = paste0("GWAS/eQTL All Tissues and \nGlobal/Cluster GWAS/caQTL Colocalization Stats")) + xlab("Trait") + ylab("Count") + scale_fill_manual(values=c("#FF4000","#E69F00","#56B4E9"),labels=c("Lead GWAS Signals Colocalized with caQTL Only","Lead GWAS Signals Colocalized with caQTL and eQTL","Lead GWAS Signals Colocalized with eQTL Only"),name="") + theme(legend.text=element_text(size=14))
ggsave(paste0("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Figures/Fig4_supplemental_gwas_all_eqtl_tissues_caqtl_bulk_and_cluster_stats_allRuns_vars_stackedBarplot.0.01.noBL.png"),p, height=8, width=15, unit ="in")





#######################################################################################################
#####Supplementary Figure 39 - Proportion of GWAS Signals explained by eQTLs/global+cluster caQTLs#####
#######################################################################################################

########Global + cluster analysis#############
library(ggplot2)
library(tidyr)
library(data.table)
library(forcats)
library(dplyr)

x <- read.table("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.clusterAnalyses/11_1_24_analyses/filteredPeakAnalyses_0.5/gwas_coloc/allPheno_allTissue_gwas_eqtl_bulk_cluster_caqtl_colocStats.10.26.24.txt",header=T,sep='\t')

#add proportions explained
x$prop_gwas_caqtl <- (x$Lead.GWAS.Variants.Colocalize.with.caQTL.and.eQTL+x$Lead.GWAS.Variants.Colocalize.with.caQTL.Only)/x$Independent.Lead.GWAS.Signals.Tested
x$prop_gwas_eqtl <- (x$Lead.GWAS.Variants.Colocalize.with.caQTL.and.eQTL+x$Lead.GWAS.Variants.Colocalize.with.eQTL.Only)/x$Independent.Lead.GWAS.Signals.Tested
x$prop_gwas_total <- (x$Lead.GWAS.Variants.Colocalize.with.caQTL.and.eQTL+x$Lead.GWAS.Variants.Colocalize.with.eQTL.Only+x$Lead.GWAS.Variants.Colocalize.with.caQTL.Only)/x$Independent.Lead.GWAS.Signals.Tested


#pivot to longer format
y <- pivot_longer(x,c("prop_gwas_caqtl","prop_gwas_eqtl","prop_gwas_total"))
y <- as.data.frame(y)
y$name <- factor(y$name,levels=c("prop_gwas_caqtl","prop_gwas_eqtl","prop_gwas_total"),ordered=TRUE)
y$name <- gsub("prop_gwas_caqtl","Proportion of GWAS Signals Explained by Global and Cluster caQTLs",y$name)
y$name <- gsub("prop_gwas_eqtl","Proportion of GWAS Signals Explained by eQTLs",y$name)
y$name <- gsub("prop_gwas_total","Proportion of GWAS Signals Explained by Global/Cluster caQTLs and eQTLs",y$name)
y <- y %>% mutate(name = fct_relevel(name,c('Proportion of GWAS Signals Explained by Global/Cluster caQTLs and eQTLs','Proportion of GWAS Signals Explained by eQTLs','Proportion of GWAS Signals Explained by Global and Cluster caQTLs')))


#plot
p <- ggplot(y, aes(x=value, y=name,fill=name)) + geom_boxplot() + ggtitle("Proportion of GWAS Explained by Global/Cluster caQTLs and eQTLs") + scale_x_continuous(breaks=seq(0,1,0.2))
p <- p + theme(legend.position="none") + theme(axis.title.x=element_blank(), axis.title.y=element_blank()) + theme(plot.title = element_text(hjust = 0.5)) 
ggsave("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/MultiTissue_Paper_Figures/supplementary_proportion_gwas_explained_global_cluster_caqtls_boxplot.10.26.24.png",p,height=6,width=12,dpi=1200,unit='in')




#######################################################################################
#####Supplementary Figure 41 - Alternate Genotype PC caQTL Mapping Results Overlap#####
#######################################################################################

library(data.table)
library(dplyr)
library(ggvenn)
library(eulerr)
library(qvalue)


#read in data
pc5 <- fread("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/tensorQTL/10.9.24_analyses/tensorQTL_results/tensorqtl_yuanAllSamples_10.9.24_prinComp200_5_gt_pcs.allChr.cis_qtl.txt.gz")

pc3 <- fread("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/tensorQTL/10.9.24_analyses/tensorQTL_results/tensorqtl_yuanAllSamples_10.9.24_prinComp200_allChr.cis_qtl.txt.gz")


#filter for fdr5 peaks
pc5_filt <- pc5 %>% dplyr::filter(qval <= 0.05)
pc3_filt <- pc3 %>% dplyr::filter(qval <= 0.05)

#venn diagram
caqtlOverlapList <- list("Five Genotype PCs"=unique(pc5_filt$phenotype_id),"Three Genotype PCs"=unique(pc3_filt$phenotype_id))
fit <- euler(caqtlOverlapList)

png("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/tensorQTL/10.9.24_analyses/tensorQTL_results/5_genotypePCs_vs_3_genotypePCs_caqtl_overlap.png",height=8,width=12,units="in",res=400)
plot(fit,quantities = TRUE,fill=c("#fc8d59", "#998ec3"),main="FDR5 caQTL Peaks Identified",legend = TRUE,)
dev.off()





####################################################################
#####Supplementary Figure 42 - Correlation of PCs with Metadata#####
####################################################################

library(data.table)
library(sjlabelled)
library(dplyr)
library(ggplot2)
library(stringr)

z<-read.table("sampleList.txt")

colnames <- fread("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/tensorQTL/sampleCols.txt",header=F)

pcs <- read.table("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/tensorQTL/10.9.24_analyses/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.noBL.txt.QTLsorted.txt.BW.norm.pcs.10.9.24.txt",header=T,row.names = 1)
samps <- as.data.frame(t(colnames[,5:1458]))
colnames(samps) <- c("Samples")

pcs_new <- cbind(samps,pcs)
pcst <- as.data.frame(t(pcs_new))
pcst_order <- t(as.data.frame(pcst[1,]))
pcst_order <- as.data.frame(pcst_order)
colnames(pcst_order) <- "sampOrd"

metadata <- fread("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/final_caQTL_mappingMetadata.txt")
metadata_sub <- data.frame(metadata$study_accession,metadata$run_accession,metadata$base_count,metadata$Tissue_Cell_Type,metadata$Combined_Tissue_Cell_Type,metadata$Cancer,metadata$Cell_Line,metadata$Primary_Tissue,metadata$Differentiated,metadata$projNum)
colnames(metadata_sub) <- gsub("metadata.","",colnames(metadata_sub))

pcs_gt <- read.table("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/tensorQTL/genotype/qcvcf.eigenvec")
pcs_gt <- pcs_gt[,-1]
colnames(pcs_gt) <- c("IID",paste0("GT_PC",rep(2:ncol(pcs_gt)-1)))

#add genotype pcs to other metadata
metadata_int <- merge(metadata_sub,pcs_gt,by.x="run_accession",by.y="IID")
final <- metadata_int[match(pcst_order$sampOrd,metadata_int$run_accession),]

metadata_num <- apply(final, 2, to_numeric)

metadata_num <- apply(metadata_sub, 2, to_numeric)

#remove unknown from final
final_removed <- final %>% dplyr::filter(!Cancer == "UNKNOWN")
final_removed_2 <- final_removed %>% dplyr::filter(!Cell_Line == "UNKNOWN")
final_removed_3 <- final_removed_2 %>% dplyr::filter(!Primary_Tissue == "UNKNOWN")
final_removed_4 <- final_removed_3 %>% dplyr::filter(!Differentiated == "UNKNOWN")
final_removed_4 <- na.omit(final_removed_4)

#get only 200 PCs
pcst_200 <- pcst[0:201,]

#linear model
pcMod <- lm(formula = t(pcst_200) ~ metadata_num)

pcst <- t(pcst_200)
pcst <- as.data.frame(pcst)
pcst_filt <- pcst %>% dplyr::filter(Samples %in% final_removed_4$run_accession)
pcst_run <- as.data.frame(pcst_filt[,-1])
pcst_run <- apply(pcst_run, 2, to_numeric)


metadata_sub_final <- data.frame(final_removed_4$base_count,final_removed_4$Cancer,final_removed_4$Cell_Line,final_removed_4$Primary_Tissue,final_removed_4$Differentiated,final_removed_4$projNum)
metadata_sub_final_boolean <- yesNoBool(metadata_sub_final,"final_removed_4.Cancer")
metadata_sub_final_boolean <- yesNoBool(metadata_sub_final_boolean,"final_removed_4.Cell_Line")
metadata_sub_final_boolean <- yesNoBool(metadata_sub_final_boolean,"final_removed_4.Primary_Tissue")
metadata_sub_final_boolean <- yesNoBool(metadata_sub_final_boolean,"final_removed_4.Differentiated")

metadata_num <- apply(metadata_sub_final_boolean, 2, to_numeric)

allCorrelations <- data.frame()
for (q in 1:ncol(pcst_run)){
  for (z in 1:ncol(metadata_num)){
    correlation <- cor.test(pcst_run[,q],metadata_num[,z])
    corValue <- correlation$estimate
    pVal <- correlation$p.value
    PCnum <- q
    metadata_col <-  colnames(metadata_num)[z]
    df <- data.frame(PCnum,metadata_col,corValue,pVal)
    allCorrelations <- rbind(allCorrelations,df)
  }
}

#run bonferroni correction
allCorrelations$qval <- p.adjust(allCorrelations$pVal,method = "bonferroni")

#filter for significant
allCorrelations_filt <- allCorrelations %>% dplyr::filter(qval <= 0.05)
allCorrelations_filt$metadata_col <- gsub("final_removed_4.","",allCorrelations_filt$metadata_col)
allCorrelations_filt$metadata_col <- gsub("_"," ",allCorrelations_filt$metadata_col)
allCorrelations_filt$metadata_col <- str_to_title(allCorrelations_filt$metadata_col)
allCorrelations_filt$metadata_col <- gsub("Projnum","Number of Samples in Project",allCorrelations_filt$metadata_col)
allCorrelations_filt$Correlation <- allCorrelations_filt$corValue

#plot ggtile
ggplot(allCorrelations_filt, aes(x = PCnum, y = metadata_col, fill = Correlation)) + geom_tile() + xlab("Principal Component") + ylab("Metadata Field") + ggtitle("Correlation of Metadata\nwith Principal Components (Pearson)") + theme(text = element_text(size = 16))
ggsave("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/tensorQTL/10.9.24_analyses/pc_metadata_correlation.pearson.png",height=10,width=10,unit="in")


##SPEARMAN

allCorrelations <- data.frame()
for (q in 1:ncol(pcst_run)){
  for (z in 1:ncol(metadata_num)){
    correlation <- cor.test(pcst_run[,q],metadata_num[,z],method="spearman")
    corValue <- correlation$estimate
    pVal <- correlation$p.value
    PCnum <- q
    metadata_col <-  colnames(metadata_num)[z]
    df <- data.frame(PCnum,metadata_col,corValue,pVal)
    allCorrelations <- rbind(allCorrelations,df)
  }
}

#run bonferroni correction
allCorrelations$qval <- p.adjust(allCorrelations$pVal,method = "bonferroni")

#filter for significant
allCorrelations_filt <- allCorrelations %>% dplyr::filter(qval <= 0.05)
allCorrelations_filt$metadata_col <- gsub("final_removed_4.","",allCorrelations_filt$metadata_col)
allCorrelations_filt$metadata_col <- gsub("_"," ",allCorrelations_filt$metadata_col)
allCorrelations_filt$metadata_col <- str_to_title(allCorrelations_filt$metadata_col)
allCorrelations_filt$metadata_col <- gsub("Projnum","Number of Samples in Project",allCorrelations_filt$metadata_col)
allCorrelations_filt$Correlation <- allCorrelations_filt$corValue

#plot ggtile
ggplot(allCorrelations_filt, aes(x = PCnum, y = metadata_col, fill = Correlation)) + geom_tile() + xlab("Principal Component") + ylab("Metadata Field") + ggtitle("Correlation of Metadata\nwith Principal Components (Spearman)") + theme(text = element_text(size = 16))
ggsave("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/tensorQTL/10.9.24_analyses/pc_metadata_correlation.spearman.png",height=10,width=10,unit="in")


####anova

metadata_anova <- data.frame(metadata$Tissue_Cell_Type,metadata$Combined_Tissue_Cell_Type)
colnames(metadata_anova) <- gsub("metadata.","",colnames(metadata_anova))

#get only 200 PCs
pcst_200_anova <- apply(pcst, 2, to_numeric)


#create df
pc_df <- data.frame(pcst_200_anova)
metadata_df <- data.frame(group=final$Combined_Tissue_Cell_Type)

combined <- cbind(pc_df,metadata_df)
combined$group <- as.factor(combined$group)

anova_result <- manova(as.matrix(pc_df) ~ group, data = combined)
manova_summary <- summary.aov(anova_result)

#get p values
allPvals <- data.frame()
for (x in (1:200)){
  p_values <- manova_summary[[x]]$"Pr(>F)"
  p_values_df <- data.frame(x,p_values[1])
  allPvals <- rbind(allPvals,p_values_df)
}

#add col names
colnames(allPvals) <- c("PC","P-values")

allPvals$qvalue <- p.adjust(allPvals$"P-values",method="bonferroni")
allPvals$log_qvalues <- -log10(allPvals$qvalue)

ggplot(data=allPvals, aes(x=PC, y=log_qvalues)) +
  geom_line(color="red")+
  geom_point() + xlab("Principal Component") + ylab("-log10(ANOVA q-value)")

ggsave("PCs_correlate_metadata.png")





####################################################################
#####Supplementary Figure 42 - RASQUAL caQTL Mapping Results########
####################################################################


library(data.table)
library(dplyr)
library(ggplot2)

featID <- read.table("featureIDLoopFinal.txt")

allResults <- data.frame()
for (feat in featID$V1){
  
  file <- fread(paste0("rasqualSubsetSamples.",feat,".rasqualResults.txt"))
  allResults <- rbind(allResults,file)
  
  
}

#add column names
colnames(allResults) <- c("Feature_ID","rs_ID","Chromosome","SNP_position","Ref_Allele","Alt_Allele","Allele_Frequency","HWE_Chi_Sq_Stat","Imputation_Qual_Score","Log_10_BH_Qvalue","Chi_Sq_Stat","Effect_Size","Sequencing/mapping_error_rate_(Delta)","Ref_Allele_Mapping_Bias","Overdispersion","SNP_ID_Within_Region","No_Feature_SNPs","No_Tested_SNPs","No_Iterations_For_Null","No_Iterations_For_Alt","RandomLocationOfTies","LogLikelihoodOfNull","ConvergenceStatus","fSNPS_geno_corr","rSNP_geno_corr")

#remove skipped rows
allResults_filt <- allResults %>% dplyr::filter(!rs_ID == "SKIPPED")


#write to file
write.table(allResults_filt,"all_rasqual_results.txt",row.names=F,col.names=T,quote=F,sep='\t')


#plot distribution of reference allele mapping bias
ggplot(allResults_filt, aes(x=Ref_Allele_Mapping_Bias))+ geom_histogram(color="darkblue", fill="lightblue",breaks=seq(0,1,0.01)) + xlab("All RASQUAL Tests Reference Allele Mapping Bias") + ylab("Counts") + theme_bw() + theme(text=element_text(size=28))
ggsave("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/manuscript_review_analyses/rasqualAnalyses/rasqual_caqtl_peak_analyses_refAlleleMappingBias_allTests.10.24.24.png",width=14,height=10,dpi=1000)


#read in all rasqual results
allResults_filt <- fread("all_rasqual_results.txt",header=T)

#get for lead caQTLs in paper
lead_caqtls <- read.table("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/tensorQTL/10.9.24_analyses/tensorQTL_results/tensorqtl_yuanAllSamples_10.9.24_prinComp200_allChr.cis_qtl.fdr5.txt",header=T)

#filter rasqual results for lead tensorqtl caQTLs
allResults_filt_caQTL_leads <- allResults_filt %>% dplyr::filter(rs_ID %in% lead_caqtls$variant_id)

#write to file
write.table(allResults_filt_caQTL_leads,"tensorQTL_lead_caQTL_rasqual_results.txt",row.names=F,col.names=T,quote=F,sep='\t')


#get median for each variant
lead_caQTLs_refAlleleMappingBias <- allResults_filt_caQTL_leads %>% group_by(rs_ID) %>% summarise(median = median(Ref_Allele_Mapping_Bias, na.rm = TRUE))
lead_caQTLs_refAlleleMappingBias <- data.table(lead_caQTLs_refAlleleMappingBias)

#plot distribution of reference allele mapping bias for lead caQTLs
ggplot(lead_caQTLs_refAlleleMappingBias, aes(x=median))+ geom_histogram(color="darkblue", fill="lightblue",breaks=seq(0,1,0.01)) + xlab("caQTL Lead Variant RASQUAL Tests Median\n Reference Allele Mapping Bias") + ylab("Counts") + theme_bw() + theme(text=element_text(size=28))
ggsave("/project/voight_viz/bwenz/multiTissue_caQTL_Mapping/manuscript_review_analyses/rasqualAnalyses/rasqual_caqtl_peak_analyses_refAlleleMappingBias_caQTL_vars_median.10.24.24.png",width=10,height=10,dpi=1000)

#get percent passing filters
phi_filt <- allResults_filt_caQTL_leads %>% dplyr::filter(Ref_Allele_Mapping_Bias < .75 & Ref_Allele_Mapping_Bias > .25)

dim(allResults_filt_caQTL_leads)
#[1] 38938    25

dim(phi_filt)s
#[1] 38660    25

#38660/38938 = 0.992


#get percent passing filters
phi_filt <- allResults_filt_caQTL_leads %>% dplyr::filter(Ref_Allele_Mapping_Bias < .6 & Ref_Allele_Mapping_Bias > .4)

dim(allResults_filt_caQTL_leads)
#[1] 38938    25

dim(phi_filt)
#[1] 33849   25

#33849/38938 = 0.869305



#all results
dim(allResults_filt)
#[1] 1515552      25

phi_filt_allResults <- allResults_filt %>% dplyr::filter(Ref_Allele_Mapping_Bias < .75 & Ref_Allele_Mapping_Bias > .25)

dim(phi_filt_allResults)
#[1] 1504374      25

#1504374/1515552
#[1] 0.9926245

phi_filt_allResults <- allResults_filt %>% dplyr::filter(Ref_Allele_Mapping_Bias < .6 & Ref_Allele_Mapping_Bias > .4)

dim(phi_filt_allResults)
#[1] 1302770      25

#1302770/1515552
#[1] 0.859601

