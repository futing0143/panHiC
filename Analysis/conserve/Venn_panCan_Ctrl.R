pacman::p_load(ggplot2,tidyverse,egg,ggVennDiagram,VennDiagram,cowplot)
setwd('/cluster2/home/futing/Project/panCancer/Analysis/conserve')
ctrl=read.csv('/cluster2/home/futing/Project/panCancer/Analysis/conserve/midata/412/strict/Ctrl_50k800kbin_id.bed',check.names=F)
panCan=read.csv('/cluster2/home/futing/Project/panCancer/Analysis/conserve/midata/412/strict/panCan_50k800kbin_id.bed',check.names=F)
Venndata=list(
  CTRL=ctrl$chrom_start_end,
  panCancer=panCan$chrom_start_end
)
p<-
ggVennDiagram(Venndata) +
  # scale_fill_manual(values=c("#16365F","white","#D64F38"))
  scale_fill_gradient2(low = "#16365F",mid="white", high = "#D64F38",midpoint = 500)+
  coord_flip()
  scale_x_continuous(expand = expansion(mult = .2))

p
ggdraw(rotate(p, 90))
