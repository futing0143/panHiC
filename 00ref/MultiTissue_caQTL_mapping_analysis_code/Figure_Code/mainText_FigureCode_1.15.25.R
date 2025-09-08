##############
###FIGURE 1###
##############


path=/user/path/


####################################################
####################################################
############Figure 1a - Project overview############
####################################################
####################################################


#Figure created with BioRender.com.




####################################################
####################################################
#Figure 1b - Plot showing sample counts per project#
####################################################
####################################################






#load packages
library(data.table)
library(ggplot2)
library(dplyr)
library(tidyverse)
library(ggrepel)


#read in data
projectCounts <- fread("/path/sampleCountPerProject.txt",header=T)
colnames(projectCounts) <- c("Project","SampleCount")

# Create Data
data <- data.frame(
  group=c(">100","50<n<100","20<n<50","10<n<20","<10"),
  value=c(10,25,87,132,399)
)

data <- data %>% 
  mutate(prop = value / sum(data$value) *100)

df2 <- data %>% 
  mutate(csum = rev(cumsum(rev(value))), 
         pos = value/2 + lead(csum, 1),
         pos = if_else(is.na(pos), value/2, pos))

p <- ggplot(data, aes(x = "" , y = value, fill = fct_inorder(group))) +
  geom_col(width = 1, color = 1) +
  coord_polar(theta = "y") +
  scale_fill_manual(values = c(">100" = "#d7191c", "50<n<100" = "#fdae61", "20<n<50" = "#ffffbf", "10<n<20" = "#abd9e9", "<10" = "#2c7bb6")) + 
  geom_text_repel(data = df2,
                  aes(y = pos, label = paste0(round(prop), "%")),
                  size = 8, nudge_x = 1, show.legend = FALSE) +
  guides(fill = guide_legend(title = "Project Sample Size")) + theme_void() 

q <- p + theme(legend.text = element_text(size=20),legend.title = element_text(size=20)) 
ggsave("/path/Fig1b_pie_sampleCountPerProject.1.10.25.png",q,height=10,width=10)


#######################################
#######################################
#Figure 1c - Plot showing sample types#
#######################################
#######################################




#load packages
library(data.table)
library(ggplot2)
library(dplyr)
library(tidyverse)

#read in data
metadata <- fread("/path/peakCallingMetadata_final.txt",header=T)
colnames(metadata) <- gsub(" ","_",colnames(metadata))
colnames(metadata) <- gsub("/","_",colnames(metadata))



#plot - filter out low values first


metadata %>% group_by(Combined_Tissue_Cell_Type) %>% count %>% filter(n > 5) %>% arrange(desc(n)) %>% ggplot(aes(x = reorder(Combined_Tissue_Cell_Type, n), y = n)) + geom_bar(stat = "identity",color="darkblue", fill="lightblue") + theme(text = element_text(size = 10),axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + xlab("Tissue/Cell") + ylab("Count") +  coord_flip()

ggsave("/path/Fig1c_all_peakCalling_samples_metadata.png")
  
  


  
#####################################################
#####################################################
#Figure 1d - Barlot showing sample types - cell line#
#####################################################
#####################################################

#stacked barplot

#load packages
library(data.table)
library(ggplot2)
library(dplyr)
library(tidyverse)

#read in data
metadata <- fread("/path/peakCallingMetadata_final.txt",header=T)
colnames(metadata) <- gsub(" ","_",colnames(metadata))
colnames(metadata) <- gsub("/","_",colnames(metadata))


#grab relevant columns
metadata_toPlot <- data.frame(metadata$Cell_Line,metadata$Primary_Tissue,metadata$Combined_Tissue_Cell_Type,metadata$Cancer,metadata$Differentiated)
colnames(metadata_toPlot) <- c("Cell_Line","Primary","Type","Cancer","Differentiated")

#ggplot stacked barplot
df_forPlot <- metadata_toPlot %>% pivot_longer(-Type)
df_forPlot <- data.frame(df_forPlot)

#modify for plot
df_forPlot$value <- str_to_title(df_forPlot$value)

df_forPlot$name = factor(df_forPlot$name, levels = c("Cell_Line","Primary","Cancer","Differentiated"), ordered = TRUE)
df_forPlot$name <- gsub("_"," ",df_forPlot$name)

p <- ggplot(df_forPlot, aes(x = fct_relevel(name, "Cell Line","Primary","Cancer","Differentiated"))) + geom_bar(aes(fill = value))
q <- p + theme(text=element_text(size=24),axis.title.x = element_blank(),axis.title.y = element_blank(),axis.text.x = element_text(angle = 45, hjust=1),legend.title=element_blank())

ggsave("/path/Fig1d_stackedBarplots_sampleAttributes.png",q)





##############
###FIGURE 2###
##############






#########################################
#########################################
#Figure 2a/b - Genotype Pipeline Stats###
#########################################
#########################################

library(tidyverse)
library(reshape2)
library(ggplot2)
library(viridis)
library(cowplot)
library(dplyr)
# detach("package:reshape2", unload=TRUE)

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
dat = dat[dat$method != 'Y_linear_regression', ]
dat = dat[dat$method != 'Y_logistic_regression', ]
dat = dat[dat$method != 'Y_ordinal_regression', ]
dat = dat[dat$method != 'Gencove_noQC', ]
dat = dat[dat$method != 'Y_random_forest', ]
dat$method = factor(dat$method, levels = c("GC", "Imputation", "Gencove"),
                    labels = c("GATK Genotype caller", "GATK Genotype caller + Imputation", "Gencove"))


# Number of variants
dat_number = dat[,c("sample", "minDP", "Number", "method")]

dat_number = dat_number[!duplicated(dat_number),]
median = dat_number %>% group_by(method, minDP) %>% summarise(median = median(Number))
sde = dat_number %>% group_by(method, minDP) %>% summarise(sde = sd(Number))

median_sed = merge(median, sde, by = c("method", "minDP"))
median_sed = median_sed[median_sed$minDP == 2, ]

g_metrics = ggplot(data = median_sed, aes(x = method, y=median, color = method, fill = method)) +
  geom_histogram(stat = 'identity')+
  geom_ribbon(aes(ymax = median + sde, ymin = median - sde,  fill = method), alpha = 0.3, color = "grey") +
  xlab('') +
  ylab('Number of called variants') +
  scale_color_viridis(discrete = TRUE) +
  scale_fill_viridis(discrete = TRUE)+
  theme_bw() + 
  theme(legend.position= "none") + 
  theme(axis.text.x = element_text(angle = 35, hjust = 1),axis.text.y = element_text(size=11), axis.title.y = element_text(size=12))
ggsave(paste0("results/Fig1A.png"), g_metrics, height = 5, width = 3)


# Spearman correlation
median = dat %>% group_by(method, minDP) %>% summarise(median = median(correlation))
sde = dat %>% group_by(method, minDP) %>% summarise(sde = sd(correlation))

median_sed = merge(median, sde, by = c("method", "minDP"))

median_sed = median_sed[median_sed$minDP == 2, ]

g_metrics = ggplot(data = median_sed, aes(x = method, y=median, color = method, fill = method)) +
  geom_histogram(stat = 'identity')+
  geom_ribbon(aes(ymax = median + sde, ymin = median - sde,  fill = method), alpha = 0.3, color = "grey") +
  xlab('') +
  ylab('Spearman correlation') +
  scale_color_viridis(discrete = TRUE) +
  scale_fill_viridis(discrete = TRUE)+
  theme_bw() + 
  theme(legend.position= "none") + 
  theme(axis.text.x = element_text(angle = 35, hjust = 1),axis.text.y = element_text(size=11), axis.title.y = element_text(size=12))
ggsave(paste0("results/Fig1A_2.png"), g_metrics, height = 5, width = 3)




# Subsampling

dt = read.table('../../data/Performance/Overall_performance_Gencove_newPipeline.txt', sep='\t', header=T)
dt = dt[dt$N2 == 7496638, ]
#dt = dt[sapply(dt$sample, function(x) grepl('S', x)), ]

qc_dat = read.table('../../data/Performance/subampling_qc.txt', sep='\t')
qc_dat = qc_dat[qc_dat$V2 == 'effective_coverage_min', ]

dt = merge(dt, qc_dat, by.x = 'sample', by.y = 'V1')
dt = dt[,c("sample", "V5", "correlation", "MSE")]
dt = melt(dt, id.vars = c('sample', 'V5'))
dt$variable = factor(dt$variable, labels = c("Correlation", "MSE"))

scaleFUN <- function(x) sprintf("%.3f", x)
p1 = ggplot(data = dt, aes(x = V5, y=value, color = variable)) +
  geom_point()+
  geom_smooth(formula = y~x, size = 1, method = "loess")+
  facet_wrap(~variable, scales="free_y", ncol=1) + 
  xlab('Effective coverage') +
  scale_color_manual(values = c("red", "blue")) +
  guides(fill=guide_legend(title="Method")) +
  theme_bw() +
  #geom_ribbon(aes(ymax = median + sde, ymin = median - sde,  fill = variable), alpha = 0.3, color = "NA") +
  guides(fill = FALSE) + 
  theme(axis.text=element_text(size=11),
        axis.title = element_text(size=12),
        strip.text = element_text(size=12)) +
  scale_y_continuous(labels=scaleFUN)

ggsave(paste0("../../results/Subsampling_cov_cor.png"), p1, height = 3, width = 4)





#########################################
#########################################
#Figure 2c - Genotype Pipeline Stats###
#########################################
#########################################

setwd('~/Downloads/Variant_calling/')
library(ggplot2)
library(viridis)

## GBR new pipeline Gencove pi1

# Pi1
dat1 = read.table(paste0('data/Evaluation_metrics/MACS2_minDP3_topVariant_cisDist_pi1_called_repInReal.txt'), sep='\t', header = T)
dat1$discovery = "Accuracy"
#dat = dat[dat$method == 'VCF_files', ]

dat2 = read.table(paste0('data/Evaluation_metrics/MACS2_minDP3_topVariant_cisDist_pi1_real_repInCalled.txt'), sep='\t', header = T)
dat2$discovery = "Recall"
#dat2 = dat2[dat2$method == 'VCF_files', ]

dat3 = read.table(paste0('data/Evaluation_metrics/Gencove_MACS2_topVariant_cisDist_pi1_called_repInReal.txt'), sep='\t', header = T)
dat3$discovery = "Accuracy"

dat4 = read.table(paste0('data/Evaluation_metrics/Gencove_MACS2_topVariant_cisDist_pi1_real_repInCalled.txt'), sep='\t', header = T)
dat4$discovery = "Recall"

dat = rbind(dat1, dat2, dat3, dat4)
#dat$window = factor(dat$window)
dat = dat[dat$method!= 'Integration',]
dat$method = factor(dat$method, levels = c("VCF_files", 'Imputation', "Gencove"),
                    labels = c("GATK Genotype caller", "GATK Genotype caller + Imputation", "Gencove"))

dat = dat[(dat$window == 500) | (dat$window == 100000), ]
dat$window  = dat$window / 1000
dat$window = factor(dat$window)

g = ggplot(data = dat, aes(x = window, y = pi1, fill=method)) + 
  facet_wrap(~discovery)+ 
  geom_bar(stat = "identity", position = 'dodge') + 
  xlab('Window size [kb]') + 
  ylab(' ') + 
  scale_fill_viridis(discrete = TRUE, option = "D") + 
  theme_bw() + 
  theme(axis.text.x=element_text(angle = 0, hjust = 0.5,size=11)) + 
  theme(axis.text.y=element_text(size=11),
        axis.title = element_text(size=12),
        strip.text = element_text(size=12))

ggsave(paste0('results/Fig2C.png'), height = 3, width = 5)





################################
################################
#Figure 2d/e - Sample Summary###
################################
################################

library(readr)
library(dplyr)
library(plyr)
library(ggplot2)
library(ComplexHeatmap)

setwd('~/Desktop/Desktop - He’s MacBook Pro (2)/Variant_calling/')

qc_metrics = read_delim('data/GEO_samples/Quality_control_metrics.txt', delim = '\t')
colnames(qc_metrics) = c("Sample", "Metric", "Type", "Standard", "Value", "Pass")

samples = unique(qc_metrics$Sample)
failed_sample = qc_metrics %>% filter(Pass == 'failed') %>% pull("Sample")
passed_sample = setdiff(samples, failed_sample)

# Number of sequenced reads
number_reads = qc_metrics %>% filter(Metric == "bases_min") %>% filter(Sample %in% passed_sample)
mu <- ddply(number_reads, "Pass", summarise, grp.mean=mean(Value))
g = ggplot(number_reads, aes(x=Value)) + 
  geom_histogram(fill = "transparent",  color="#003a72") +
  scale_x_log10() + 
  xlab('') + 
  ggtitle('Distribution of sequenced reads number') +
  ylab('Number of samples') + 
  geom_vline(xintercept = 3000000000, color="grey") + 
  geom_vline(data=mu, aes(xintercept=grp.mean),color="#003a72", linetype="dashed") + 
  theme_bw()
ggsave(paste0("results/GEO_samples_number_reads.png"), g, height = 2.5, width = 4)


# effection coverage
eff_cov = qc_metrics %>% filter(Metric == "effective_coverage_min") %>% filter(Sample %in% passed_sample)
mu <- ddply(eff_cov, "Pass", summarise, grp.mean=mean(Value))
g = ggplot(eff_cov, aes(x=Value)) + 
  geom_histogram(fill="transparent",  color = "#003a72") +
  xlab('') + 
  ggtitle('Distribution of effective coverage')+ 
  ylab('Number of samples') + 
  geom_vline(data=mu, aes(xintercept=grp.mean), color="#003a72", linetype="d[ashed") + 
  theme_bw()
ggsave(paste0("results/GEO_samples_eff_cov.png"), g, height = 2.5, width = 4)


# number of snps 
snps = qc_metrics %>% filter(Metric == "snps_min")  %>% filter(Sample %in% passed_sample)
snps$Value = snps$Value / 1000000
mu <- ddply(snps, "Pass", summarise, grp.mean=mean(Value))
g = ggplot(snps, aes(x=Value)) + 
  geom_histogram(fill="transparent",  color = "#003a72") +
  scale_x_log10() + 
  xlab('') + 
  ggtitle('Distribution of number of snps (in Million) \n with >=1 reads') +
  ylab('Number of samples') + 
  geom_vline(data=mu, aes(xintercept=grp.mean, color=Pass), color="#003a72", linetype="dashed") + 
  theme_bw()
ggsave(paste0("results/GEO_samples_number_snps.png"), g, height = 2.5, width = 4)


## failed samples
failed_samples = qc_metrics %>% filter(Pass == 'failed') %>% pull(Sample)
failed_metrics = qc_metrics %>% filter(Sample %in% failed_samples)
failed_metrics = failed_metrics%>% filter(Pass == 'failed')

g = ggplot(failed_metrics, aes(x=Metric)) + 
  geom_histogram(fill="transparent",  color = "#A2A2A1FF", stat = 'count') +
  xlab('Reported error information') + 
  ylab('Number of samples') + 
  #geom_vline(xintercept = 3000000000, linetype="dashed", color = "blue", size=1) + 
  ggtitle(paste0('For ',length(unique(failed_metrics$Sample)),' failed samples')) + 
  theme_bw() + 
  theme(axis.text.x = element_text(angle = 75, hjust = 1)) 
ggsave(paste0("results/GEO_samples_failed_samples.png"), g, height = 5, width = 5)


## Studies

studies = read_delim('data/SraRunTables/SraRunTable_noSC.csv', delim = ',')

number_samples = table(studies %>% pull(BioProject))
mu = mean(number_samples)

number_samples = data.frame(table(number_samples))
number_samples$number_samples = as.numeric(as.character(number_samples$number_samples))

right_side = sum(number_samples[number_samples$number_samples >= 50, "Freq"])
number_samples = number_samples[number_samples$number_samples < 50, ]
number_samples = rbind(number_samples, c(50, right_side))

g = ggplot(data = number_samples, aes(x = number_samples, y=Freq)) + 
  geom_histogram(stat = 'identity', fill="transparent",  color = "#003a72") +
  xlab('') + 
  geom_vline(aes(xintercept=mu), linetype="dashed") + 
  ylab('') +
  ggtitle('Distribution of study sample size') + 
  theme_bw() + 
  scale_x_continuous(breaks = c(1, 10, 20, 30, 40, 50), 
                     labels = c("1", "10", "20", "30", "40", ">=50"))
ggsave(paste0("results/Study_sample_numbers.png"), g, height = 2.5, width = 4)


# source
studies = read_delim('data/SraRunTables/SraRunTable_noSC.csv', delim = ',')
sample_source = studies %>% pull(source_name)
sample_source = table(sample_source)
#sample_source = sample_source[sample_source$n > 20, ]
#sample_source = sample_source[sample_source!='NA', ]
sample_source = sample_source[complete.cases(sample_source)]

#sample_source$source_name = factor(sample_source$source_name, 
#                                   levels = as.character(sample_source$source_name)[(order(sample_source$n))])
#sample_source = sample_source[sample_source$n > 30, ]

sample_source = data.frame(sample_source)
sample_source$sample_source = factor(sample_source$sample_source, 
                                     levels = as.character(sample_source$sample_source)[(order(sample_source$Freq))])

g = ggplot(data = sample_source, aes(x = "", y=Freq, fill = sample_source)) + 
  geom_bar(stat = 'identity') + 
  xlab('') + 
  ylab('Distribution of sample conditions') + 
  theme_bw() + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size=11)) + 
  coord_polar("y", start=0) + 
  theme(legend.position = 'None') 

ggsave(paste0("results/Study_sources.png"), g, height = 3, width = 3.5)


## Genetic correlation
Spearman_cor = read_delim('data/SraRunTables/correlation.csv', delim = '\t')
df_cor = dcast(Spearman_cor[,c("sample1", "sample2", "Pearson_correlation")], sample2 ~ sample1)
rownames(df_cor) = df_cor$sample2
df_cor = df_cor[, rownames(df_cor)]
df_cor[is.na(df_cor)] = 0

col_fun = colorRamp2(c(0.2,0.6, 1), c("white", "grey","blue"))
png(paste0("results/Sample_structure_overall.png"), width=600, height=470)
Heatmap(as.matrix(df_cor), 
        col = col_fun, 
        name = "Spearman correlation",
        show_column_dend = FALSE,
        show_row_dend = FALSE)
dev.off()



studies = read_delim('data/SraRunTables/SraRunTable_noSC.csv', delim = ',')

number_samples = studies %>% group_by(BioProject) %>% tally()
number_samples[number_samples$n > 50, ]

study = 'PRJNA484801'
study = 'PRJNA388006'
#study = 'PRJNA306685'
samples = studies %>% filter(BioProject == study) %>% pull(Run)
samples_cor = Spearman_cor %>% filter(sample1 %in% samples) %>% filter(sample2 %in% samples)
dt_spearman = dcast(samples_cor[,c("sample1", "sample2", "Pearson_correlation")], sample2 ~ sample1)
rownames(dt_spearman) = dt_spearman$sample2

samples = samples[samples %in% colnames(dt_spearman)]
dt_spearman = dt_spearman[, samples]


donors = read.table(paste0('data/SraRunTables/',study,'_donors.txt'), header = F, stringsAsFactors = F, sep=',')
#donors$V2 = paste0(donors$V3, "_", donors$V2)
#donors$V2 = as.character(donors$V3)
rownames(donors) = donors$V1

assigned_donors = read.table('data/SraRunTables/correlation_Spearman_sample_structure.csv', sep = '\t', stringsAsFactors = F)
assigned_donors$samples = rownames(assigned_donors)

donor_in_this_study = donors[samples, "V2"]
assigned_donors_in_this_study = assigned_donors[samples, 'sample_levels']
assigned_donors_in_this_study[assigned_donors_in_this_study == 'S294'] = 'Donor 1'
assigned_donors_in_this_study[assigned_donors_in_this_study == 'S295'] = 'Donor 2'
assigned_donors_in_this_study[assigned_donors_in_this_study == 'S296'] = 'Donor 3'
assigned_donors_in_this_study[assigned_donors_in_this_study == 'S297'] = 'Donor 4'
assigned_donors_in_this_study[assigned_donors_in_this_study == 'S298'] = 'Donor 5'
assigned_donors_in_this_study[assigned_donors_in_this_study == 'S299'] = 'Donor 6'
assigned_donors_in_this_study[assigned_donors_in_this_study == 'S300'] = 'Donor 7'
assigned_donors_in_this_study[assigned_donors_in_this_study == 'S301'] = 'Donor 8'
assigned_donors_in_this_study[assigned_donors_in_this_study == 'S302'] = 'Donor 9'
assigned_donors_in_this_study[assigned_donors_in_this_study == 'S303'] = 'Donor 10'
assigned_donors_in_this_study[assigned_donors_in_this_study == 'S558'] = 'Donor 11'


library(circlize)
col_fun = colorRamp2(c(0.2,0.6, 1), c("white", "grey","blue"))
ccs = brewer.pal(11, "BrBG")
sample_col_fun = c("Donor 1"= ccs[1], 
                   "Donor 2"= ccs[2], 
                   "Donor 3"= ccs[3], 
                   "Donor 4"= ccs[4], 
                   "Donor 5"= ccs[5], 
                   "Donor 6"= ccs[6], 
                   "Donor 7"= ccs[7], 
                   "Donor 8"= ccs[8], 
                   "Donor 9"= ccs[9], 
                   "Donor 10"= ccs[10], 
                   "Donor 11"= ccs[11])
ha = HeatmapAnnotation("True donor" = as.vector(donor_in_this_study), 
                       "Assigned donor" = as.vector(assigned_donors_in_this_study),
                       col = list("True donor" = sample_col_fun, "Assigned donor" = sample_col_fun))

dt_plot = as.matrix(dt_spearman)
rownames(dt_plot) = seq(1, dim(dt_plot)[1])
colnames(dt_plot) = seq(1, dim(dt_plot)[1])

png(paste0("results/Sample_structure_", study, ".png"), width=600, height=350)
Heatmap(dt_plot, 
        col = col_fun, 
        name = "Spearman correlation",
        top_annotation = ha,
        show_column_dend = FALSE,
        show_row_dend = FALSE)
dev.off()

samples_cor$donor1 = donors[samples_cor$sample1, "V2"]
samples_cor$donor2 = donors[samples_cor$sample2, "V2"]


# Number of Series vs. year

studies = read_delim('data/SraRunTables/SraRunTable_all.txt', delim = ',')
number_series = studies[c("BioProject", "ReleaseDate")]
number_series = number_series[!duplicated(number_series),]
#number_series$Date = as.vector(sapply(number_series$ReleaseDate, function(x) format(paste(strsplit(as.character(x), '-')[[1]][1], strsplit(as.character(x), '-')[[1]][2], sep = '-'), format="%Y-%m")))
number_series$Date = as.vector(sapply(number_series$ReleaseDate, function(x) format(strsplit(as.character(x), ' ')[[1]][1], format="%Y-%m-%d")))

number_by_date = number_series %>% group_by(Date) %>% mutate(count = n())
number_by_date = number_by_date[c("Date", "count")]
number_by_date = number_by_date[!duplicated(number_by_date), ]

number_by_date = as_tibble(as.data.frame(number_by_date))
number_by_date = number_by_date[order(number_by_date$Date), ]
number_by_date_cumsum = number_by_date %>%
  mutate(Date = ymd(Date)) %>%
  mutate(cumsum = cumsum(count))


png("results/Number_ATAC.png", width = 500, height = 350, res = 100)
plot(cumsum ~ Date, number_by_date_cumsum, xaxt = "n", yaxt = 'n', type = "l", ylab = 'Number of ATAC-seq GEO studies', xlab = 'Time')
axis(1, number_by_date_cumsum$Date, format(number_by_date_cumsum$Date, "%m/%y"), cex.axis = 1)
axis(side = 2,
     ## Rotate the labels.
     las = 2,
     ## Adjust the label position.
     mgp = c(3, 0.75, 0))
dev.off()





##############
###FIGURE 3###
##############





#######################
#######################
#Figure 3a - Histogram#
#######################
#######################





library(ggplot2)
library(data.table)

#plot peak lengths
peaks <- fread("/path/cpm_peakInfo.txt",header=T)
peaks$length <- peaks$End-peaks$Start

#plot peak length histogram
ggplot(peaks, aes(x=length))+ geom_histogram(color="darkblue", fill="lightblue",bins=100) + xlim(0,1000) + xlab("Peak Length (bp)") + ylab("Counts") + theme_bw() + theme(text=element_text(size=28))
ggsave("/path/Fig3a_multitissuePeaks_length.png",width=10,height=10,dpi=1000)





############################
############################
#Figure 3b - Manhattan plot#
############################
############################





library(ggplot2)
library(data.table)
library(dplyr)
library(qqman)

#read in results

lead_caqtls <- read.table("/path/tensorqtl_yuanAllSamples_4.10.24_prinComp200_allChr.cis_qtl.FDR5only.txt",header=T)


allVariant_AF <- data.frame()
#loop throgh all chr
for (chr in (1:22)){
AF_file <- fread(paste0("/path/chr",chr,".allFinalSamples.AF_filesForColoc.txt"))
allVariant_AF <- rbind(allVariant_AF,AF_file)
}


lead_caqtls_withInfo <-merge(lead_caqtls,allVariant_AF,by.x="variant_id",by.y="ID")
colnames(lead_caqtls_withInfo) <- gsub("#","",colnames(lead_caqtls_withInfo))  

#gwasResultsFinal <- gwasResultsFinal %>% filter(-log10(permutation2)> 5)

don <- lead_caqtls_withInfo %>% 
  
  # Compute chromosome size
  group_by(CHROM) %>% 
  summarise(chr_len=max(POS)) %>% 
  
  # Calculate cumulative position of each chromosome
  mutate(tot=cumsum(as.numeric(chr_len))-chr_len) %>%
  select(-chr_len) %>%
  
  # Add this info to the initial dataset
  left_join(lead_caqtls_withInfo, ., by=c("CHROM"="CHROM")) %>%
  
  # Add a cumulative position of each SNP
  arrange(CHROM, POS) %>%
  mutate( BPcum=POS+tot)

#prep x axis
axisdf = don %>% group_by(CHROM) %>% summarize(center=( max(BPcum) + min(BPcum) ) / 2 )

#make plot
ggplot(don, aes(x=BPcum, y=-log10(pval_beta))) + xlab("Chromosome") + ylab("-log10(p-value)") +
  
  # Show all points
  geom_point( aes(color=as.factor(CHROM)), alpha=0.8, size=1.3) +
  scale_color_manual(values = rep(c("grey", "skyblue"), 22 )) +
  
  # custom X axis:
  scale_x_continuous( label = axisdf$CHROM, breaks= axisdf$center ) +
  #scale_y_continuous(expand = c(0, 0) ) +     # remove space between plot area and x axis
  
  # Custom the theme:
  theme_bw() +
  theme( 
    legend.position="none",
    panel.border = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    axis.title.x = element_text(size=28),
    axis.title.y = element_text(size=28),
    axis.text.x=element_text(size=18,hjust = 0, vjust = 0),
    axis.text.y=element_text(size=20)
  ) 

ggsave("/path/Fig3b_multiTissue_allFasqtl_manhattanPlot.ggplot.png",width=12,height=8,dpi=1000)





#############################################
#############################################
#Figure 3c - Within Feature caQTL Enrichment#
#############################################
#############################################





library(ggplot2)
library(dplyr)

#read in lead caqtl info
lead_caqtls <- read.table("/path/tensorqtl_yuanAllSamples_4.10.24_prinComp200_allChr.cis_qtl.FDR5only.txt",header=T)

#read in metadata
peakMetadata <- read.table("/path/cpm_peakInfo.txt",header=T)

#add peak metadata to caQTL info
lead_caqtls_withMetadata <- merge(lead_caqtls,peakMetadata,by.x="phenotype_id",by.y="Peak")

#add peak length to this df
lead_caqtls_withMetadata$peakLength <- lead_caqtls_withMetadata$End - lead_caqtls_withMetadata$Start

#get midpoint
lead_caqtls_withMetadata$peakMidpoint <- lead_caqtls_withMetadata$Start + (lead_caqtls_withMetadata$peakLength/2)

#get snp position
lead_caqtls_withMetadata$snpPosition <- lead_caqtls_withMetadata$End + lead_caqtls_withMetadata$end_distance

#get distance to midpoint
lead_caqtls_withMetadata$distanceToMidpoint <- lead_caqtls_withMetadata$snpPosition - lead_caqtls_withMetadata$peakMidpoint

#plot distance to midpoint
ggplot(lead_caqtls_withMetadata, aes(x=distanceToMidpoint))+ geom_histogram(color="darkblue", fill="lightblue") + xlim(-15000,15000) + xlab("Distance to Peak Midpoint (bp)") + ylab("Counts") + theme_bw() + theme(text=element_text(size=28))
ggsave("/path/Fig3c_lead_caQTL_distance_to_feat_midpoint.png",width=10,height=10,dpi=1000)





#############################################
#############################################
#Figure 3d - Replication in External Dataset#
#############################################
#############################################





library(data.table)
library(qvalue)
library(dplyr)
library(ggplot2)

#read in data
x <- fread("/path/africanLCL_tensorqtl_yuanAllSamples_3.10.24_prinComp200_multitissue_fdr5_multitissue_overlapSNPs_overlappingPeaks.txt")

#require that shared snp is being tested with overlapping peak
peakOverlap <- x %>% dplyr::filter(phenotype_id == V54)


#get pi1
pi1 = 1 - qvalue::qvalue(peakOverlap$pvalue)$pi0

#plot overlap p value histogram
ggplot(peakOverlap, aes(x=pvalue))+ geom_histogram(color="darkblue", fill="lightblue") + xlab("Replication P-values") + ylab("Counts") + theme_bw() + theme(text=element_text(size=28))
ggsave("/path/Fig3d_africanLCL_multitissue_overlappingPeaks_andVars.rawPvals.png",width=10,height=10,dpi=1000)





#####################################################################################
#####################################################################################
#############FIGURE 4 - Colocalizations across caQTL, eQTL, GWAS summary#############
#####################################################################################
#####################################################################################




library(data.table)
library(dplyr)
library(tidyverse)
library(splitstackshape)

clump_par = 0.01


tissueList <- fread("/path/gtexTissueList.txt",header=F)

key = read.table("/path/phenoKey.txt")
#key$V2 <- gsub("Neutrophill","Neutrophil",key$V2)
#key$V2 <- gsub("Eosinophill","Eosinophil",key$V2)

gwasLeads <- fread("/path/allLeadGwas.txt")
gwasLeads <- cSplit(gwasLeads,"V2",sep="/")

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
    
    if (file.exists(paste0("/path/eQTL_GWAS/",pheno,"_",tissue,"_all_chr.eQTL_coloc.pruned.",clump_par,".newGTF.8.21.24.txt"))){
      if (file.exists(paste0("/path/eQTL_GWAS/",pheno,"_",tissue,"_all_chr.eQTL_coloc.pruned.",clump_par,".newGTF.8.21.24.filtered.txt"))){
        if (file.info(paste0("/path/eQTL_GWAS/",pheno,"_",tissue,"_all_chr.eQTL_coloc.pruned.",clump_par,".newGTF.8.21.24.filtered.txt"))$size > 1){
          colocFinal <- fread(paste0("/path/eQTL_GWAS/",pheno,"_",tissue,"_all_chr.eQTL_coloc.pruned.",clump_par,".newGTF.8.21.24.filtered.txt"),header=T)
          allTissueDF <- rbind(allTissueDF,colocFinal)
        }else{
          print("no colocs")
        }
        
      }else{
        x <- fread(paste0("/path/eQTL_GWAS/",pheno,"_",tissue,"_all_chr.eQTL_coloc.pruned.",clump_par,".newGTF.8.21.24.txt"))
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
          
          
          write.table(colocFinal,paste0("/path/eQTL_GWAS/",pheno,"_",tissue,"_all_chr.eQTL_coloc.pruned.",clump_par,".newGTF.8.21.24.filtered.txt"),sep="\t",row.names = FALSE, col.names = TRUE, quote = F)
        }     
      }
      
      #combine results to combined df
      combined_df <- rbind(combined_df,colocFinal)
      
    }
    
    #old results
    if (file.exists(paste0("/path/",pheno,"_colocResults/",pheno,"_",tissue,"_all_chr.eQTL_coloc.pruned.",clump_par,".4.24.24.txt"))){
      if (file.exists(paste0("/path/",pheno,"_colocResults/",pheno,"_",tissue,"_all_chr.eQTL_coloc.pruned.",clump_par,".4.24.24.filtered.txt"))){
        if (file.info(paste0("/path/",pheno,"_colocResults/",pheno,"_",tissue,"_all_chr.eQTL_coloc.pruned.",clump_par,".4.24.24.filtered.txt"))$size > 1){
          colocFinal <- fread(paste0("/path/",pheno,"_colocResults/",pheno,"_",tissue,"_all_chr.eQTL_coloc.pruned.",clump_par,".4.24.24.filtered.txt"),header=T)
          allTissueDF <- rbind(allTissueDF,colocFinal)
        }else{
          print("no colocs")
        }
        
      }else{
        x <- fread(paste0("/path/",pheno,"_colocResults/",pheno,"_",tissue,"_all_chr.eQTL_coloc.pruned.",clump_par,".4.24.24.txt"))
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
          
          
          
          write.table(colocFinal,paste0("/path/",pheno,"_colocResults/",pheno,"_",tissue,"_all_chr.eQTL_coloc.pruned.",clump_par,".4.24.24.filtered.txt"),sep="\t",row.names = FALSE, col.names = TRUE, quote = F)
        }     
      }
      #add data to combined df
      combined_df <- rbind(combined_df,colocFinal)
    }
    
    #write combined file 
    write.table(combined_df,paste0("/path/eQTL_GWAS/",pheno,"_",tissue,"_all_chr.eQTL_coloc.pruned.",clump_par,".newGTF.8.21.24.old_new.filtered.txt"),row.names=F,col.names=T,quote=F,sep='\t')
    
    
    #remove chr from lead gwas
    allTissueDF$leadGwasVariant <- gsub("chr","",allTissueDF$leadGwasVariant)
    
    
    #read in caqtl-gwas
    if (file.exists(paste0("/path/",pheno,"_colocResults/",keyTrait,"_",pheno,"_multiTissue_allPeaks_coloc.pruned.",clump_par,"_allColocResults.Final.filtered.withStats.10.19.24.txt"))){
      
      caQTL_colocs <- fread(paste0("/path/",pheno,"_colocResults/",keyTrait,"_",pheno,"_multiTissue_allPeaks_coloc.pruned.",clump_par,"_allColocResults.Final.filtered.withStats.10.19.24.txt"))
      
      
      #get overlap
      overlap <- intersect(caQTL_colocs$gwas_lead,allTissueDF$leadGwasVariant)
      
      #get caqtl and eqtl specific lead gwas variant colocs
      caqtl_specific <- setdiff(caQTL_colocs$gwas_lead,allTissueDF$leadGwasVariant)
      eqtl_specific <- setdiff(allTissueDF$leadGwasVariant,caQTL_colocs$gwas_lead)
      
      #get data frame for caQTL only gwas colocalization
      caQTL_only_df <- caQTL_colocs %>% dplyr::filter(gwas_lead %in% caqtl_specific)
      
      
      
      clusterDF <- data.frame(keyTrait,length(overlap),length(caqtl_specific),nrow(caQTL_colocs),length(eqtl_specific),nrow(allTissueDF),lead_gwas_num)
      colnames(clusterDF) <- c("Pheno","Lead GWAS Variants Colocalize with caQTL and eQTL","Lead GWAS Variants Colocalize with caQTL Only","Total Number of caQTL/GWAS Colocalizations","Lead GWAS Variants Colocalize with eQTL Only","Total Number of eQTL/GWAS Colocalizations","Independent Lead GWAS Signals Tested")
      
      clusterDF <- na.omit(clusterDF)
    }
  }
  allPhenoTissue <- rbind(allPhenoTissue,clusterDF)
  print("tissues")
  print(length(unique(allTissueDF$Tissue)))
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

#write to file
write.table(stats,"/path/allPheno_allTissue_gwas_eqtl_colocStats.10.19.24.txt",row.names=F,col.names=T,quote=F,sep='\t')


#subset analysis - all stats
stats_subset <- data.frame(stats$Pheno,stats$Total_Number_of_caQTL_GWAS_Colocalizations,stats$Total_Number_of_eQTL_GWAS_Colocalizations)
colnames(stats_subset) <-  gsub("stats.","",colnames(stats_subset))
colnames(stats_subset) <- gsub("_"," ",colnames(stats_subset))
stats_subset$Pheno <- make.unique(stats_subset$Pheno)


p <- stats_subset %>% mutate(Label = Pheno) %>% reshape2::melt(.) %>% ggplot(., aes(x = reorder(Label, -value), y = value, fill = variable)) + geom_bar(stat='identity')
p <- p + theme(axis.text.x = element_text(angle = 45, hjust=1,size=7),plot.margin = margin(10, 100, 10, 30)) + labs(title = paste0("GWAS eQTL All Tissue and GWAS/caQTL Colocalization Stats")) + xlab("Trait") + ylab("Count")


ggsave(paste0("/path/Fig4_supplemental_gwas_all_eqtl_tissues_caqtl_stats_allRuns_stackedBarplot.0.01.noBL.10.19.24.png"),p, height=8, width=15, unit ="in")


#get subset oriented on variants
stats_subset_var <- data.frame(stats$Pheno,stats$Lead_GWAS_Variants_Colocalize_with_caQTL_Only,stats$Lead_GWAS_Variants_Colocalize_with_caQTL_and_eQTL,stats$Lead_GWAS_Variants_Colocalize_with_eQTL_Only)
colnames(stats_subset_var) <-  gsub("stats.","",colnames(stats_subset_var))

#change column names to remove spaces
colnames(stats_subset_var) <- gsub("_"," ",colnames(stats_subset_var))




#all traits
p <- stats_subset_var %>% mutate(Label = Pheno) %>% reshape2::melt(.) %>% ggplot(., aes(x = reorder(Label, -value), y = value, fill = variable)) + geom_bar(stat='identity')
p <- p + theme(axis.text.x = element_text(angle = 45, hjust=1,size=7),plot.margin = margin(10, 100, 10, 30)) + labs(title = paste0("GWAS/eQTL All Tissues and GWAS/caQTL Colocalization Stats")) + xlab("Trait") + ylab("Count") + scale_fill_manual(values=c("#FF4000", "#E69F00", "#56B4E9"))

ggsave(paste0("/path/Fig4_supplemental_gwas_all_eqtl_tissues_caqtl_stats_allRuns_vars_stackedBarplot.0.01.noBL.10.19.24.png"),p, height=8, width=15, unit ="in")


#get sum of gwas lead variants that colocalize
for (z in 1:nrow(stats_subset_var)){
  stats_subset_var$sum[z] <- sum(stats_subset_var[z,2:4])
}

#filter out traits with fewer colocalizations

stats_subset_var_filt <- stats_subset_var %>% dplyr::filter(!sum < 50)
stats_subset_var_final <- stats_subset_var_filt[,1:4]
stats_subset_var_final$Pheno <- make.unique(stats_subset_var_final$Pheno)
stats_subset_var_final$Pheno <- gsub("Weight.1","Weight (impedance)",stats_subset_var_final$Pheno)
stats_subset_var_final$Pheno <- gsub("Body Mass Index \\(Bmi)\\.1","Body Mass Index (impedance)",stats_subset_var_final$Pheno)


p <- stats_subset_var_final %>% mutate(Label = Pheno) %>% reshape2::melt(.) %>% ggplot(., aes(x = reorder(Label, -value), y = value, fill = variable)) + geom_bar(stat='identity') + theme_bw() + theme(legend.position="bottom")
p <- p + theme(axis.text.x = element_text(angle = 45, hjust=1,size=11), legend.text=element_text(size=11),plot.margin = margin(10, 100, 10, 30)) + labs(title = paste0("GWAS/eQTL All Tissues and GWAS/caQTL Colocalization Stats")) + xlab("Trait") + ylab("Count") + scale_fill_manual(values=c("#FF4000","#E69F00","#56B4E9"),labels=c("Lead GWAS Signals Colocalized with caQTL Only","Lead GWAS Signals Colocalized with caQTL and eQTL","Lead GWAS Signals Colocalized with eQTL Only"),name="") 
ggsave(paste0("/path/Fig4_gwas_all_eqtl_tissues_caqtl_stats_allRuns_vars_stackedBarplot.0.01.noBL.filtered.10.19.24.png"),p, height=12, width=15, unit ="in")





#######################################################################
#######################################################################
#########Figure 5 - Colocalizing caQTL/eQTL/GWAS locus example#########
#######################################################################
#######################################################################



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
multiTissue_peak = "peak_252469"
tissue = "Whole_Blood"
gene = "ENSG00000125618.16"
chrom = 2
pheno = "30670_irnt"
geneName = "PAX8"
print(geneName)

#read in key
key = fread("/path/phenoKeyForFigures.txt",header=F)

#get pheno info
phenoInfo=key %>% dplyr::filter(V1==pheno)
keyTrait = as.character(phenoInfo$V2)

#read in peak metadata
peakMetadata <- read.table("/path/cpm_peakInfo.txt",header=T)

#get metadata for peak of interest
peakMetadata_filt <- peakMetadata %>% dplyr::filter(Peak == multiTissue_peak )


#read in rsid file loop
all_idFile <- data.frame()
idFile <- fread(paste0("/path/Kaviar-160204-Public-hg38-trim.noHead.vcf.chr",chrom,".vcf.gz"))
idFile$variant <- paste0(idFile$V1,"_",idFile$V2,"_",idFile$V4,"_",idFile$V5,"_b38")
all_idFile <- rbind(all_idFile,idFile)


#read in AF data loop
allMultiTissueAF <- data.frame()

multiTissueAF = read.table(paste0("/path/chr",chrom,".allFinalSamples.AF_filesForColocFinal.txt"),header=T)
multiTissueAF = within(multiTissueAF, INFO<-data.frame(do.call('rbind', strsplit(as.character(INFO), '=', fixed=TRUE))))
AF=as.character(multiTissueAF$INFO$X4)
multiTissueAF$MAF = as.numeric(AF)
multiTissueAF$match <- paste0(multiTissueAF$CHROM,":",multiTissueAF$POS)

allMultiTissueAF <- rbind(allMultiTissueAF,multiTissueAF)


#read in caqtl data
multiTissue_stats = fread(paste0("/path/tensorqtl_yuanAllSamples_4.10.24_prinComp200_allTests_allChr.cis_qtl_pairs.",chrom,".FDR5.peaks.txt"),header=T)
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
eqtl <- fread(paste0("/project/voight_datasets_01/GTEx_v8/TissueSpecific/",tissue,".allpairs.txt.gz"),header=T)
eqtl <- eqtl %>% dplyr::filter(gene_id==gene)
eqtl$variant = gsub("chr","",eqtl$variant_id)

#merge eqtl and caqtl data
m = merge(eqtl, multiTissueFinal, by="variant")

#data check
print("m")
print(m)
print(nrow(m))


#read in gwas data

gwas = fread(paste0("/path/chosenTraits_bw/",pheno,"/",pheno,"_hg38_chr",chrom,".txt.gz"))
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
open_gwas_jwt="eyJhbGciOiJSUzI1NiIsImtpZCI6ImFwaS1qd3QiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJhcGkub3Blbmd3YXMuaW8iLCJhdWQiOiJhcGkub3Blbmd3YXMuaW8iLCJzdWIiOiJid2VuekB1cGVubi5lZHUiLCJpYXQiOjE3MzY1MTYwMDQsImV4cCI6MTczNzcyNTYwNH0.KI0UOpgqqLVlRDDepOgCvc4PHMR3GH-YXEQiJtEKc_Rt1p7jE5JvVTCJULsRgYaoX_Xp_0www0abBOE-OksKHW7JhltnRtlk8AE0e8SwKWIKSjBQv7q34JXqyWXMK-foZueZ6iZ08GOxoPFczt7C66F0FJdq-t2Bq4Xg0Ef42xmJOA0tjmKyH78omeQvyL2nCKcQZ6p0CVO_o16Sb-4jIiADxbQTREtlP_lRc18XJFc0_6toL4aKSyqkLiWauVr-IIOyo3uflfOuRy-UY4Hg-vy_9To5Z9V4QZQP5PVxR_SnAVfqkkuB1CkbVWUJb-DEm76ktN1L1p7AxX1ViWrQGw"
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

p1 <- gg_scatter(caqtl_loc,size=3,cex.axis = 1.5,cex.lab = 1.5, pcutoff=F,labels = "index",nudge_x = 0.03, ylab=paste0("Coloc ",multiTissue_peak,"\n-log10( caQTL p value)")) + theme(axis.title.y=element_text(angle=0,vjust = 0.5))
p2 <- gg_scatter(eqtl_loc,size=3,cex.axis = 1.5,cex.lab = 1.5, pcutoff=F,labels = "index", nudge_x = 0.03,ylab=paste0("Coloc GTEx ",tissue," ",geneName, "\n-log10(eQTL p value)"))+theme(axis.title.y=element_text(angle=0,vjust = 0.5))
p5 <- gg_scatter(gwas_loc,size=3, cex.axis = 1.5,cex.lab = 1.5,pcutoff=F,labels = "index", nudge_x = 0.03,ylab=paste0("Coloc ",keyTrait,"\n -log10(GWAS p value)"))+theme(axis.title.y=element_text(angle=0,vjust = 0.5))
p3 <- gg_scatter(eqtl_overlay_loc,size=3, cex.axis = 1.5,cex.lab = 1.5,pcutoff=F,labels = "index", nudge_x = 0.03,ylab=paste0("GTEx ",tissue," ",geneName,"\n-log10(eQTL p value)"))+theme(axis.title.y=element_text(angle=0,vjust = 0.5))
p6 <- gg_scatter(all_gwas_loc,size=3,cex.axis = 1.5,cex.lab = 1.5,pcutoff=F, labels = "index", nudge_x = 0.03,ylab=paste0(keyTrait,"\n -log10(GWAS p value)"))+theme(axis.title.y=element_text(angle=0,vjust = 0.5))
p4 <- gg_genetracks(caqtl_loc,cex.lab=1.5,cex.axis = 1.5,cex.text=1.5) 

#plot and save
plot_grid(p1, p2, p5, p3, p6, p4, ncol = 1,align = "v")

ggsave(paste0("/path/",multiTissue_peak,"_",tissue,"_",geneName,"_",keyTrait,".1.10.25.pdf"), width = 12, height = 12)




##################################################################
##################################################################
#########Figure 6 - ATAC-seq clustering and caQTL mapping#########
##################################################################
##################################################################





################################################
################################################
#########Figure 6a - Clustering results#########
################################################
################################################





library(readr)
library(umap)
library(ggplot2)
require("sfsmisc")
library("fpc")
library(data.table)
library(dplyr)

set.seed(71)

#all samples averaged
peak_dat = fread('/path/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.peaksRemoved.QuantNormReadValuesCPM.txt',header=F)

sampleNames = read.table('/path/sampleList.txt',header=F)
colnames(peak_dat) = sampleNames$V1


#remove outlier samples
finalSamples = read.table('sampleList.noOutliers.txt',header=F)

df = peak_dat %>% select(matches(finalSamples$V1))

samples = colnames(df)


cluster.umap = umap(t(as.matrix(df)))

layout = cluster.umap$layout
dp = data.frame("X1"=layout[,1], "X2" = layout[,2])
dp_plot =  dp

cal_dp_plot=dp_plot

for (i in (1:20)){
  
  kmeans_result = kmeans(dp_plot[,c(1,2)], centers = i)
  print(i)
  
  
  
  dp_plot$clusterID = factor(kmeans_result$cluster)
  write.table(dp_plot,col=T,row=T,sep="\t",quote=F,file=paste0("all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.",i,"clusters.allPeaks.noOutliers.6.28.24.txt"))
  
  cbPalette <- c(
    "#E69F00",  # Orange
    "#56B4E9",  # Sky Blue
    "#b8e186",  # brown
    "#F0E442",  # Yellow
    "#0072B2",  # Blue
    "#D55E00",  # Vermilion
    "#CC79A7",  # Reddish Purple
    "#999999",  # Gray
    "#44AA99",  # Teal Green
    "#882255",  # Dark Red
    "#117733"   # Forest Green
  )
  
  g = ggplot(data = dp_plot) +
    geom_point(aes(x = X1, y = X2, color = clusterID))  +
    theme_bw() +
    ggtitle("") +
    xlab('UMAP 1') +
    ylab('UMAP 2') +
    scale_color_manual(values=cbPalette) +
    theme(text=element_text(size=24)) +
    guides(color = guide_legend(override.aes = list(size = 4))) +
    labs(color='Cluster ID') +
    theme(legend.title=element_text(size=14))
  
  ggsave(paste0("Figure6a_ClusteringResults",i,"_Clusters.pdf"),g, height = 12, width = 10)
  
  
  
  round(calinhara(cal_dp_plot,kmeans_result$cluster),digits=2)
  print(round(calinhara(cal_dp_plot,kmeans_result$cluster),digits=2))
}





###########################################################
###########################################################
#########Figure 6b - Cluster caQTL Mapping Summary#########
###########################################################
###########################################################





library(htmltools)
library(webshot)    
library(data.table)
library(dplyr)
library(formattable)
library(tidyr)

export_formattable <- function(f, file, width = "100%", height = NULL, 
                               background = "white", delay = 0.2)
{
  w <- as.htmlwidget(f, width = width, height = height)
  path <- html_print(w, background = background, viewer = NULL)
  url <- paste0("file:///", gsub("\\\\", "/", normalizePath(path)))
  webshot(url,
          file = file,
          selector = ".formattable_widget",
          delay = delay,zoom=3)
}



x<-fread("/path/allCluster_results_stats.txt")
x$`Percent of Cluster caQTLs Replicating in Bulk caQTLs` <- x$`Percent of Cluster caQTLs Replicating in Bulk caQTLs` * 100
colnames(x) <- c("Cluster","Sample Size","Number of Projects\n In Cluster","Number of FDR5 caQTLs","Percent of Cluster caQTLs\n Replicating in Global caQTLs")

ft <- formattable(x, list("Sample Size" = color_bar("#e9c46a"),"Number of Projects\n In Cluster" = color_bar("#e66101"),"Number of FDR5 caQTLs" = color_bar("#48cae4"),"Percent of Cluster caQTLs\n Replicating in Global caQTLs" = color_bar("#c2a5cf")),table.attr = 'style="font-size: 50px; font-family: Calibri";\"')


export_formattable(ft,"Multitissue_paper_6b_barVersion.png",height = 1500, width = 1500)





#######################################################################
#######################################################################
#########Figure 6c - caQTL Mapping Cluster-Cluster Replication#########
#######################################################################
#######################################################################





library(stats)
library(pheatmap)
library(stats)
library(tidyverse)
library(subset)
library(reshape2)
library(grid)
library(formattable)
library(reactablefmtr)

optimized_file <- fread("/path/pc_optimization_final.txt",header=T)


#get cluster overlap
allCluster_cluster_Replication <- data.frame()
for (i in (1:11)){
  ref <- fread(paste0("/path/cluster",i,"/cluster",i,"_fdr5_caqtls.txt"))
  
  
  for (cluster in (1:11)){
    clusterRow <- optimized_file %>% dplyr::filter(Cluster == cluster)
    prinComp <- clusterRow$PCs
    
    cluster_qtls <- fread(paste0("/path/cluster",cluster,"/prinComp_",prinComp,"/tensorqtl_cluster",cluster,"_prinComp",prinComp,"_allChr_4.3.24.cis_qtl.txt.gz"),header=T)
    
    comp_values_ref_qtls <- cluster_qtls %>% dplyr::filter(phenotype_id %in% ref$phenotype_id)
    
    #get pi1
    all_pi1 <- data.frame()
    for (x in seq(from=0.05,to=0.95,by=0.05)){
      pi1 =  1 - qvalue_truncp(comp_values_ref_qtls$pval_nominal,lambda = x)$pi0
      all_pi1 <- rbind(all_pi1,pi1)
    }
    
    print(all_pi1)
    
    colnames(all_pi1) <- c("All")
    median <- median(all_pi1$All)
    medianDF <- data.frame(i,cluster,median)
    allCluster_cluster_Replication <- rbind(allCluster_cluster_Replication,medianDF)
  }
}

colnames(allCluster_cluster_Replication) <- c("ReferenceCluster","ComparisonCluster","pi1")

#write to file
write.table(allCluster_cluster_Replication,"/path/cluster_cluster_replication_pi1.txt",col.names=T,row.names=F,sep='\t',quote=F)

#plot
nameVals <- sort(unique(unlist(allCluster_cluster_Replication[1:2])))
# construct 0 matrix of correct dimensions with row and column names
myMat <- matrix(0, length(nameVals), length(nameVals), dimnames = list(nameVals, nameVals))

# fill in the matrix with matrix indexing on row and column names
myMat[as.matrix(allCluster_cluster_Replication[c("ReferenceCluster", "ComparisonCluster")])] <- allCluster_cluster_Replication[["pi1"]]

#plot - no clustering
pheatmap(myMat,cluster_rows=F,cluster_cols=F,file="/path/cluster_cluster_replication_pi1_noClustering.png")


















