library(TCGAbiolinks)
TCGAbiolinks:::getGDCprojects()$project_id
TCGAbiolinks:::getProjectSummary("TCGA-GBM")
gbmquery <- GDCquery(
  project = "TCGA-GBM", 
  data.category = "Copy Number Variation",
)
query.gbm.nocnv <- GDCquery(
  project = "TCGA-GBM",
  data.category = "Copy number variation",
  legacy = TRUE,
  file.type = "nocnv_hg19.seg",
  sample.type = c("Primary Tumor")
)
query <- GDCquery(
  project = "TCGA-CHOL", 
  data.category = "Simple Nucleotide Variation", 
  access = "open",
  data.type = "Masked Somatic Mutation", 
  workflow.type = "Aliquot Ensemble Somatic Variant Merging and Masking"
)
GDCdownload(gbmquery)
maf <- GDCprepare(query)
