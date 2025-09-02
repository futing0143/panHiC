library(scorecard)
library(survival)
library(readxl)
pFilter=0.05 
                               
# input: dataframe
# id surtime state features

#-- 循环对特征单独进行Cox分析，保存至OutTab
set.seed(123)

outTab=data.frame()
invalid=data.frame()
sigGenes=c('surtime','state')
for(i in colnames(Patient[,7:10])){
  cox <- coxph(Surv(surtime, state) ~ Patient[,i], data = Patient)
  coxSummary = summary(cox)
  coxP=coxSummary$coefficients[,"Pr(>|z|)"]
  if(is.na(coxP)){
    invalid=rbind(invalid,
                  cbind(id=i,pvalue=coxP)
    )
  }
  else if(coxP<pFilter){
    sigGenes=c(sigGenes,i)
    outTab=rbind(outTab,
                 cbind(id=i,
                       HR=coxSummary$conf.int[,"exp(coef)"],
                       HR.95L=coxSummary$conf.int[,"lower .95"],
                       HR.95H=coxSummary$conf.int[,"upper .95"],
                       pvalue=coxSummary$coefficients[,"Pr(>|z|)"])
    )
  }
  
}

###save all
for(i in colnames(Stom.TNM[,4:6])){
  cox <- coxph(Surv(surtime, state) ~ Stom.TNM[,i], data = Stom.TNM)
  coxSummary = summary(cox)
  outTab=rbind(outTab,
               cbind(id=i,
                     HR=coxSummary$conf.int[,"exp(coef)"],
                     HR.95L=coxSummary$conf.int[,"lower .95"],
                     HR.95H=coxSummary$conf.int[,"upper .95"],
                     pvalue=coxSummary$coefficients[,"Pr(>|z|)"])
  )
}

for(i in colnames(Stom.Gene[,4:ncol(Stom.Gene)])){
  cox <- coxph(Surv(surtime, state) ~ Stom.Gene[,i], data = Stom.Gene)
  coxSummary = summary(cox)
  outTab=rbind(outTab,
               cbind(id=i,
                     HR=coxSummary$conf.int[,"exp(coef)"],
                     HR.95L=coxSummary$conf.int[,"lower .95"],
                     HR.95H=coxSummary$conf.int[,"upper .95"],
                     pvalue=coxSummary$coefficients[,"Pr(>|z|)"])
  )
}
write.csv(outTab,"/Volumes/My Passport/05.Shu_84_cohort/02.UniCox/Stomach_TNM.csv")

sigGenes_hard = subset(outTab, outTab$pvalue<0.01)
sigGenes_hard = sigGenes_hard$id
sigGenes_hard = c(c('surtime','state'),sigGenes_hard)

####Train
uniSigExp=GSVA.Time.Misgdb.Train[,sigGenes_hard]
uniSigExp=cbind(id=row.names(uniSigExp),uniSigExp)
write.table(uniSigExp,file="uniSigExp_0.001_misgdb_train.txt",sep="\t",row.names=F,quote=F)

####Test
uniSigExp=GSVA.Time.Misgdb.Test[,sigGenes_hard]
uniSigExp=cbind(id=row.names(uniSigExp),uniSigExp)
write.table(uniSigExp,file="uniSigExp_0.001_misgdb_test.txt",sep="\t",row.names=F,quote=F)
