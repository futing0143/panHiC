
# 在 GO.R 后运行
pathway_name <- "GO:0014031"  # mesenchymal cell development


# Extract genes
pathway_genes <- ego@result %>% 
  filter(ID == pathway_name) %>% 
  pull(geneID) %>% 
  strsplit("/") %>% 
  unlist()

write.table(pathway_genes,
            paste0('/cluster/home/futing/Project/GBM/HiC/HAR/HARs_gene/GO_result/',pathway_name,'.txt'),
            row.names = F,col.names = F,quote=F)


# ------- save directly from dataset
library(clusterProfiler)
library(msigdbr)  #install.packages("msigdbr")
library(GSVA) 
library(GSEABase)

## 1.3 Extract gene sets using msigdbr package !!! actually using
### KEGG pathways
KEGG_df_all <- msigdbr(species = "Homo sapiens", category = "C2", subcategory = "CP:KEGG")
KEGG_df <- dplyr::select(KEGG_df_all, gs_name, gs_exact_source, gene_symbol)
kegg_list <- split(KEGG_df$gene_symbol, KEGG_df$gs_name)  # Group by pathway name

### GO pathways
GO_df_all <- msigdbr(species = "Homo sapiens", category = "C5")
GO_df <- dplyr::select(GO_df_all, gs_name, gene_symbol, gs_exact_source, gs_subcat)
GO_df <- GO_df[GO_df$gs_subcat != "HPO", ]  # Exclude HPO terms
go_list <- split(GO_df$gene_symbol, GO_df$gs_name)  # Group by pathway name

### Hallmark pathways
Hallmark_df <- msigdbr(species = "Homo sapiens", category = "H") %>% 
  dplyr::select(gs_name, gene_symbol, gs_exact_source, gs_subcat)
Hallmark_list <- split(Hallmark_df$gene_symbol, Hallmark_df$gs_name)

### Entrez IDs for GSEA
m_t2g <- msigdbr(species = "Homo sapiens", category = "H") %>% 
  dplyr::select(gs_name, entrez_gene)

