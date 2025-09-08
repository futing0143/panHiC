setwd('/cluster2/home/futing/Project/HiCQTL')
load('/cluster2/home/futing/Project/HiCQTL/.RData')
library(ClipperQTL)

RNA='/cluster2/home/futing/Project/HiCQTL/merged/CRC/phenotype/expr.bed'
covFile='/cluster2/home/futing/Project/HiCQTL/merged/CRC53/covariate/covariate27.txt'
genotypeFile='/cluster2/home/futing/Project/HiCQTL/merged/CRC53/genotype/CRC53hard/snp.out.anno.vcf.gz'
exprFile='/cluster2/home/futing/Project/HiCQTL/merged/CRC53/phenotype/CRC53_Aug15_index.bed'

genotypeFile='/cluster2/home/futing/Project/HiCQTL/tensorqtl/example/data/test.vcf.gz'
covFile='/cluster2/home/futing/Project/HiCQTL/tensorqtl/example/data/GEUVADIS.445_samples.covariates.txt'
exprFile='/cluster2/home/futing/Project/HiCQTL/tensorqtl/example/data/GEUVADIS.445_samples.expression.bed.gz'

path='/cluster2/home/futing/Project/panCancer/ClipperQTL-master/example'
path='/cluster2/home/futing/Project/HiCQTL/merged/CRC53/'
path='/cluster2/home/futing/Project/HiCQTL/tensorqtl/example/data/'
tabixProgram='~/miniforge3/envs/hic/bin/tabix'

# ------ example
#Take a look at the example expression file.
exprFile<- paste0(path,"/Whole_Blood.v8.normalized_expression.bed.gz")
temp1<-readr::read_delim(exprFile,delim="\t",escape_double=FALSE,trim_ws=TRUE) #20,315*674. Sample size is 670.

#Take a look at the example covariate file.
covFile<-paste0(path,"/Whole_Blood.v8.covariates.txt")
temp2<-readr::read_delim(covFile,delim="\t",escape_double=FALSE) #50*671.
# -------

expr <- readr::read_delim(exprFile,delim = "\t",escape_double=FALSE,trim_ws=TRUE)
covariate <- readr::read_delim(covFile,delim='\t',escape_double=FALSE,trim_ws=TRUE)
colnames(covariate)[1] <- 'ID'

# The missing genotype entries will be imputed as within-SNP averages


# #Use the standard variant of ClipperQTL.
approach<-"standard"
B<-1000


outputDir<-paste0(path,"/Clipper","approach=",approach,"_B=",B,"/")
if(!dir.exists(outputDir)) dir.create(outputDir)

library(ClipperQTL) #Loading ClipperQTL also loads dplyr. Loading dplyr is necessary for ClipperQTL() and callSigGeneSNPPairs() to run.
ClipperQTL(exprFile,covFile,genotypeFile,tabixProgram,outputDir,
           approach,B,
           cisDistance=1e6,MAFThreshold=0.01,MASamplesThreshold=10,
           numOfChunksTarget=100,seed=1,numOfCores=5)
