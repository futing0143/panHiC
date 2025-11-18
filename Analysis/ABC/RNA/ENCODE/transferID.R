library(clusterProfiler)
library(org.Hs.eg.db)

entrez_ids <- bitr(gene_list, fromType = "SYMBOL", 
                   toType = "ENTREZID", 
                   OrgDb = org.Hs.eg.db)