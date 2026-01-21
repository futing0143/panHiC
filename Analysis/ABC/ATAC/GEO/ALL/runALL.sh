#!/bin/bash


nohup /cluster2/home/futing/pipeline/newATAC/ATAC_v4.sh \
-d /cluster2/home/futing/Project/panCancer/Analysis/ABC/ATAC/GEO/ALL/GSE145997/GM12878 \
-n GM12878 \
-p yes \
-s /cluster2/home/futing/Project/panCancer/Analysis/ABC/ATAC/GEO/ALL/GSE145997/GM12878/srr.txt \
> /cluster2/home/futing/Project/panCancer/Analysis/ABC/ATAC/GEO/ALL/GSE145997/GM12878/debug/GM12878_$(date +%Y%m%d_%H%M%S).log 2>&1 &


nohup /cluster2/home/futing/pipeline/newATAC/ATAC_v4.sh \
-d /cluster2/home/futing/Project/panCancer/Analysis/ABC/ATAC/GEO/ALL/GSE145997/GM12878_engineered \
-n GM12878_en \
-s /cluster2/home/futing/Project/panCancer/Analysis/ABC/ATAC/GEO/ALL/GSE145997/GM12878_engineered/srr.txt \
> /cluster2/home/futing/Project/panCancer/Analysis/ABC/ATAC/GEO/ALL/GSE145997/GM12878_engineered/debug/GM12878_en_$(date +%Y%m%d_%H%M%S).log 2>&1 &
