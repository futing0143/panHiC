

#######################

# R code identify GWAS-related eQTLs in TCGA

#######################


library(dplyr)
library(data.table)


#read cis result
cis_file=paste0("PancanQTLv1/cis_eQTLs_all_re")
cis=fread(cis_file,head=T)

#read trans result
trans_file=paste0("PancanQTLv1/cis_eQTLs_all_re")
trans=fread(trans_file,head=T)

#cat SNPs
QTL=unique(c(cis$rs,trans$rs))

#output SNP list
fwrite(as.data.frame(QTL),"all_SNP.list",col.names = F,row.names = F,quote = F)           


## find all SNPs that are have LD>0.5 with QTL SNPs #############################

# wget http://fileserve.mrcieu.ac.uk/ld/1kg.v3.tgz

# run Plink to select SNP with LD>0.5 within 500KB
system(command = 
"plink --bfile 1kg.v3/EUR --ld-snp-list all_SNP.list --r2 --ld-window 9999999 --ld-window-kb 500 --ld-window-r2 0.5 --out all_SNP.list.500kb.LD0.5"
)

# read all_SNP.list.500kb.LD0.5.ld 
ld=fread("all_SNP.list.500kb.LD0.5.ld",header = T)
ld=transmute(ld,
             eQTL=SNP_A,
             eQTL_pos=paste0(CHR_A,":",BP_A),
             SNP=SNP_B,
             SNP_pos=paste0(CHR_B,":",BP_B),
             R2)

ld <- ld[complete.cases(ld), ]
##########################################################################################

# GWAS_Catalog
GWAS=fread("GWAS_Catalog.xls",head=T,sep = "\t", na.strings = c("", "NA", "N/A"))
GWAS=transmute(GWAS,
               SNP=SNPS,
               Trait=`DISEASE/TRAIT`,
               RISK_ALLELE=`STRONGEST SNP-RISK ALLELE`,
               OR_or_BETA=`OR or BETA`,
               P_value=`P-VALUE`,
               PUBMEDID
)

GWAS$RISK_ALLELE=gsub("^\\w+\\-","",GWAS$RISK_ALLELE,perl=T)
GWAS$RISK_ALLELE=gsub("\\-","",GWAS$RISK_ALLELE,perl=T)
GWAS$RISK_ALLELE[!grepl("A|G|C|T", GWAS$RISK_ALLELE)] <- NA
GWAS$P_value=as.numeric(GWAS$P_value)
GWAS$OR_or_BETA=as.numeric(GWAS$OR_or_BETA)


# match LD result and GWAS_Catalog

GWAS=filter(GWAS,SNP %in% ld$SNP )
ld=inner_join(GWAS,ld,by="SNP")

ld=transmute(cat,
              eQTL,
              eQTL_pos,
              GWAS_SNP=SNP,
              GWAS_SNP_pos=SNP_pos,
              R2,RISK_ALLELE,OR_or_BETA,P_value,
              Trait_or_Disease=Trait,PUBMEDID
              )

#fwrite(ld,"eQTL_GWAS_match.xls",row.names = F,col.names = T,sep="\t",quote = F,na = "NA")

QTL=rbind(cis,trans)
colnames(QTL)=c("Cancer_type","eQTL","Chr","Pos","Alleles","Gene","Gene_postion","Beta","t-stat","eQTL P_value")



QTL_GWAS=inner_join(QTL,ld,by="eQTL")

QTL_GWAS=transmute(QTL_GWAS,
                   Cancer_type,eQTL,eQTL_pos,GWAS_SNP,GWAS_SNP_pos,R2,
                   RISK_ALLELE,OR_or_BETA,P_value,Trait_or_Disease,PUBMEDID)


fwrite(QTL_GWAS,"GWAS_eQTL.out.xls",sep="\t",col.names = T,row.names = F,quote = F,na="NA")

