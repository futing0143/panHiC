library(ggplot2)
library(readxl)
library(magrittr)
library(dplyr)
library(forestplot)
library(survival)
library(survminer)
library(stringr)


setwd('/cluster/home/futing/Project/GBM/HiC/13mutation/ICGC')

survival=read.csv('/cluster/home/futing/Project/GBM/HiC/13mutation/ICGC/meta_simple.txt',sep='\t')
SM=read.csv('loopedSM/ConFreq_sur.csv',sep='\t')

pathway=
SM_short=SM[,c(1:6,3667:3670)]
colnames(SM_short)[7:10]=c('ConFreq','Orin','ConNum','ConFreqRatio')
Patient=SM_short

SNP=read.csv('/cluster/home/futing/Project/GBM/HiC/13mutation/mutation/patient_loop.csv')
SNP <- SNP %>% mutate(across(7:ncol(SNP), ~ replace_na(., 0)))
list=colnames(SNP[,7:ncol(SNP)])[order(colSums(SNP[,7:ncol(SNP)]!=0),decreasing = T)]
SNP=SNP[!is.na(SNP$PATH_DIAG_TO_LAST_CONTACT_DAYS),]
Patient=SNP[,1:6]
Patient$VITAL_STATUS=ifelse(Patient$VITAL_STATUS =='deceased',0,1)
colnames(Patient)[c(2,5)]=c("surtime",'state')

# newer import
Patient=read.csv('/cluster/home/futing/Project/GBM/HiC/13mutation/mutation_tcga/SM_Con_all.csv')
colnames(Patient)[2:7]=c("OS",'surtime','ConFreq','Orin','ConNum','ConFreqRatio')
Patient$state=ifelse(Patient$OS == "1:DECEASED",1,0)


# Patient['test']=SNP[,colnames(SNP)==list[2]]
Patient$ConFreqRatio=scale(log10(as.numeric(Patient$ConFreqRatio)+1))
Patient$ConFreqRatioG=ifelse(Patient$ConFreqRatio>=7425,"High",ifelse(Patient$ConFreqRatio<= 2603 ,"Low","Middle"))
# Patient$ConFreqRatioG=ifelse(Patient$ConFreqRatio > median(Patient$ConFreqRatio, na.rm = TRUE),"H","L")
Patient$ConFreqRatioG=ifelse(Patient$ConFreqRatio>=2603,"High","Low")

summary(Patient$ConFreqRatio)
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 0.000   1.099   1.645   2.576   2.717  19.286 



fit <- survfit(Surv(surtime,state) ~ ConFreqRatioG, data = Patient)
p <- ggsurvplot(fit, 
                ####绘图元素
                #conf.int = TRUE, # 显示置信区间
                pval = TRUE, # 添加P值
                pval.size=4,
                risk.table = TRUE,
                #surv.median.line = "hv",  # 添加中位生存时间线
                ###theme
                xlab = "Follow up time (d)", # 指定x轴标
                
                #legend = c(0.5,0.85), # 指定图例位置
                legend.title = "", # 设置图例标题
                # legend.labs=c(paste0('ConFreqRatio = ',c('H','L','M')))
                #legend.labs =c(paste0(i, "=H"), paste0(i, "=L")),
                #legend.labs = paste0('TAC = ', c(2:6)),
                #legend.labs = c("N = 0", "N = 1","N = 2","N = 3","N = 4"), # 指定图例分组标签
                #palette = "npg"
)
p
pdf("Sex.pdf",width = 7, height = 7)
print(p, newpage = FALSE)
dev.off()



# ------ legency 
######gene##################
####filter0
zeroposition <- colSums(Stom.Time[,c(9:ncol(Stom.Time))] == 0) %>% as.data.frame(.) %>% filter(.,.>=60)
zeroname <- rownames(zeroposition)

####filter p <0.05
unicox_top100 <- Stom_unicox[-which(Stom_unicox$id %in% zeroname),] %>% as.data.frame(.) %>% arrange(.,pvalue)
unicox_sig <- subset(unicox_top100,pvalue<=0.05)
#unicox_top100 <- unicox_top100$id[1:100]
###filter cancer-related gene
cancerid <- read.table('G:/05.Shu_84_cohort/02.UniCox/onco.txt') %>% as.vector(.) %>% unlist(.)
TSG <- read.table('G:/05.Shu_84_cohort/02.UniCox/TSG.txt') %>% as.vector(.) %>% unlist(.)
unicox_pval <- unicox_top100[which(unicox_top100$pvalue < 0.05),1]

onco_p <- intersect(cancerid,unicox_pval)
TSG_p <- intersect(unicox_pval,TSG)
t <- intersect(onco_p,TSG_p)

########group by 25:50:25
plot <- cbind(Stom.Gene[,c(1:3)],Stom.Gene[,c(colnames(Stom.Gene) %in% TSG_p)]) %>% as.data.frame(.)
Stom_top_group <- matrix(0,nrow(plot),ncol(plot)) %>% as.data.frame(.)
Stom_top_group[,c(1:3)] <- plot[,c(1:3)]
colnames(Stom_top_group) <- colnames(plot)
rownames(Stom_top_group) <- rownames(plot)
for (i in 4:ncol(plot))
{
  t <- plot[which(plot[,i] != 0),i] 
  cuthigh <- sort(t)[length(t)-length(t)%/%4]
  cutlow <- sort(t)[length(t)%/%4]
  for(h in 1:nrow(plot))
  {if ((plot[h,i] <= cutlow) & (plot[h,i] != 0)){Stom_top_group[h,i] <- 'low'}
    else if (as.numeric(plot[h,i]) >= cuthigh){Stom_top_group[h,i] <- 'high'}
    else if (plot[h,i] == 0){Stom_top_group[h,i] <- 'none'}
    else if ((plot[h,i] > cutlow) & (plot[h,i] < cuthigh)){Stom_top_group[h,i] <- 'middle'}}
  #Stom_top_group[which(plot[,i] <= cutlow),i] <- 'low' %>% as.factor(.)
  #Stom_top_group[which(plot[,i] >= cuthigh),i] <- 'high' %>% as.factor(.)
  #Stom_top_group[which(plot[,i] == 0),i] <- 'none' %>% as.factor(.)
  #Stom_top_group[which((plot[,i] < cuthigh)&(plot[,i] > cutlow)),i] <- 'middle'%>% as.factor(.)
}

######
gene = colnames(Stom_top_group)[4:length(Stom_top_group)]
gene = colnames(Stom.TNM)[4:5]
dat = Stom.TNM
for (i in gene){
  print(i)
  #dat = filter(Stom_top_group,Stom_top_group[,i] != 'none' & Stom_top_group[,i] != 'middle' )
  #dat[,c(4:length(dat))] <- as.factor(dat[,c(4:length(dat))])
  fit <- survfit(Surv(surtime,state) ~ dat[,i], data = dat)
  p <- ggsurvplot(fit, 
                  ####绘图元素
                  #conf.int = TRUE, # 显示置信区间
                  pval = TRUE, # 添加P值
                  pval.size=4,
                  risk.table = TRUE,
                  #surv.median.line = "hv",  # 添加中位生存时间线
                  ###theme
                  xlab = "Follow up time (d)", # 指定x轴标签
                  #font.x =
                  #legend = c(0.8,0.75), # 指定图例位置
                  legend.title = "", # 设置图例标题
                  #legend.labs =c(paste0(i, "=H"), paste0(i, "=L")),
                  legend.labs = paste0('T = ', c(2:6)),
                  #legend.labs = c("N = 0", "N = 1","N = 2","N = 3","N = 4"), # 指定图例分组标签
                  palette = "npg")
  pdf(paste0(i, "_surv2.pdf"),width = 6, height = 7)
  print(p, newpage = FALSE)
  dev.off()
  
}


