#!/bin/bash

cd /cluster2/home/futing/Project/panCancer/Analysis/ABC/ATAC
meta=/cluster2/home/futing/Project/panCancer/check/meta/panCan_annometa.txt

cut -f1,4 $meta | sort -u > \
	ATAC.txt
# 手动添加文件路径到最后一列


cut -f1-4,7,13 /cluster2/home/futing/Project/panCancer/check/meta/PanmergedMeta_0106.txt \
> /cluster2/home/futing/Project/panCancer/Analysis/ABC/ATAC/GEO/tmp


cut -f1-4,7,13 /cluster2/home/futing/Project/panCancer/check/meta/PanmergedMeta_0106.txt | \
paste - <(cut -f5-8 /cluster2/home/futing/Project/panCancer/Analysis/ABC/ATAC/GEO/ATACmeta.txt) \
> /cluster2/home/futing/Project/panCancer/Analysis/ABC/ATAC/GEO/tmp