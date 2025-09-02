library(ggplot2)
library(viridis)
library(dplyr)
library(gridExtra)
library(ggpubr)
library(Seurat)
library(anndata)
library(reticulate)
library(SeuratDisk)

use_python("/cluster/home/futing/miniforge-pypy3/envs/scRNA/bin/python")
adata <- read_h5ad("/cluster/home/Kangwen/dream/stark2.0/map10kb.h5ad")
hires=Read10X_h5("/cluster/home/futing/Project/scHiC/scGAD/output.h5",use.names = T)
adata_Seurat <- as.Seurat(ad, counts = "X", data = NULL)

#读取h5ad数据。h5ad是python的Scanpy读取文件格式，对其进行格式转换，并得到.h5seurat格式的文件
Convert('/cluster/home/futing/Project/scHiC/scGAD/map10kb.h5ad', "h5seurat",
        overwrite = TRUE)
seurat_obj <- LoadH5Seurat("/cluster/home/futing/Project/scHiC/scGAD/map10kb.h5seurat",meta.data = FALSE, misc = FALSE)
matrix_3p <- Read10X_h5("/cluster/home/futing/Project/DLBCL/harmony_test/5p_pbmc10k_filt.h5",use.names = T)
RNA=CreateSeuratObject(matrix_3p,project = "HIRES")

#-------------
cellinfo=read.csv("./meta.csv",sep = '\t')
cellinfo=cell[,c(2,1,3,4)]
rownames(cellinfo)=cellinfo$X
head(cellinfo)
geneinfo=read.csv("./geneinfo.csv")
head(geneinfo)
geneinfo=geneinfo[,c(1,2)]
head(geneinfo)
counts=ReadMtx(mtx = "./sparse_matrix.mtx",cells = "./cellinfo.csv", features = "./geneinfo.csv")
counts=Matrix::readMM(file = "./sparse_matrix.mtx")
head(counts)[,1:9]
dim(counts)
rownames(counts)=rownames(geneinfo)
colnames(counts)=rownames(cellinfo)

RNA=CreateSeuratObject(counts = counts,project = "HIRES",meta.data = cellinfo)

gad_score<- readRDS('/cluster/home/futing/Project/scHiC/scGAD/gad_score.RDS')

data=as.matrix(counts)
DataList = list(scGAD = gad_score, scRNAseq = data)
cellTypeList = list(scGAD = summary$`cell-type`, scRNAseq = cellinfo$Cell.type)

names(cellTypeList[[1]]) = summary$id
names(cellTypeList[[2]]) = colnames(RNA)


combinedAssay = runProjection(DataList, doNorm = c(FALSE, FALSE), cellTypeList)

geneList = lapply(DataList, rownames)
common_gene = Reduce(intersect, geneList)
selectGene = function(assay, genes = common_gene) {
  assay[genes, ]
}
DataList = lapply(DataList, selectGene)
nameAssays = names(DataList)
GADList = list()
for (i in 1:length(nameAssays)) {
  print(i)
  s = CreateSeuratObject(count = DataList[[i]], data = DataList[[i]])
  if (doNorm[i]) {
    s = NormalizeData(object = s)
    all.genes <- rownames(s)
    s <- ScaleData(s, features = all.genes)
  }
  else {
    s <- SetAssayData(s, assay = "RNA", slot = "scale.data", 
                      new.data = as.matrix(DataList[[i]]))
  }
  Idents(s) = cellTypeList[[i]]
  s$method = nameAssays[i]
  DefaultAssay(s) = "RNA"
  GADList[[i]] = s
}
GADList <- lapply(X = GADList, FUN = function(x) {
  x <- FindVariableFeatures(x, selection.method = "mean.var.plot", 
                            nfeatures = 2500)
})
print(1)
features <- SelectIntegrationFeatures(object.list = GADList)
suppressWarnings(getAnchors <- FindIntegrationAnchors(object.list = GADList, 
                                                      anchor.features = features, k.filter = 50))
suppressWarnings(getCombined <- IntegrateData(anchorset = getAnchors, 
                                              k.weight = 80))
DefaultAssay(getCombined) <- "integrated"
suppressWarnings(getCombined <- ScaleData(getCombined, verbose = FALSE))
getCombined <- RunPCA(getCombined, npcs = 15, verbose = FALSE)
getCombined <- RunUMAP(getCombined, reduction = "pca", dims = 1:5)
getCombined

p_celltype <- DimPlot(combinedAssay, reduction = "umap", label = TRUE, repel = TRUE, pt.size = 1.3, shape.by = "method", label.size = 8) +
  xlab("UMAP 1") +
  ylab("UMAP 2") +
  scale_color_manual(breaks = c("Hippocampal Granule Cell", "Mature Oligodendrocyte", "Microglia Etc."),
                     values = c("#1B4F72", "#F39C12", "#000000")) +
  rremove("legend")


pRNA = combinedAssay@reductions$umap@cell.embeddings %>% data.frame %>% mutate(celltype = c(cellTypeList[[1]], cellTypeList[[2]]), label = c(rep("scGAD", length(cellTypeList[[1]])), rep("scRNA-seq", length(cellTypeList[[2]])))) %>%
  filter(label == "scRNA-seq") %>%
  ggplot(aes(x = UMAP_1, y = UMAP_2, color = celltype)) +
  geom_point(size = 0.3) +
  theme_pubr(base_size = 14) +
  scale_color_manual(breaks = c("Hippocampal Granule Cell", "Mature Oligodendrocyte", "Microglia Etc."),
                     values = c("#1B4F72", "#F39C12", "#000000")) +
  xlab("UMAP 1") +
  ylab("UMAP 2") +
  rremove("legend") +
  ggtitle("Single-cell Transcriptomics") + theme(axis.title = element_blank())


pGAD = combinedAssay@reductions$umap@cell.embeddings %>% data.frame %>% mutate(celltype = c(cellTypeList[[1]], cellTypeList[[2]]), label = c(rep("scGAD", length(cellTypeList[[1]])), rep("scRNA-seq", length(cellTypeList[[2]])))) %>%
  filter(label == "scGAD") %>%
  ggplot(aes(x = UMAP_1, y = UMAP_2, color = celltype)) +
  geom_point(size = 0.3) +
  theme_pubr(base_size = 14) +
  scale_color_manual(breaks = c("Hippocampal Granule Cell", "Mature Oligodendrocyte", "Microglia Etc."),
                     values = c("#1B4F72", "#F39C12", "#000000")) +
  xlab("UMAP 1") +
  ylab("UMAP 2") +
  rremove("legend") +
  ggtitle("Single-cell 3D Genomics") +
  theme(axis.title = element_blank())


lay = rbind(c(1, 1, 2))
grid.arrange(p_celltype, arrangeGrob(pRNA, pGAD, ncol = 1, nrow = 2), layout_matrix = lay)