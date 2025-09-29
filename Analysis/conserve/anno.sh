#!/bin/bash

cd /cluster2/home/futing/Project/panCancer/Analysis/conserve
annodir=/cluster2/home/futing/Project/panCancer/GBM/HiC/09insulation/con_Boun/annotation/
end="50k800k"
bedtools intersect -a ${annodir}/Census_tss.bed \
	-b <(tail -n +2 ./panCan327_${end}.bed | cut -f1-3) \
	-wao > ./CGC_in_panCan327_${end}_all.bed
awk 'BEGIN{FS=OFS="\t"}$10 ==1' ./CGC_in_panCan327_${end}_all.bed > ./CGC_in_panCan327_${end}.bed #22/742

bedtools intersect -a ${annodir}/CGC_tss_500ud.bed -b <(tail -n +2 ./panCan327_${end}.bed | cut -f1-3) \
	-wao \
	> ./PCG_panCan327_${end}_all.bed

awk 'BEGIN{FS=OFS="\t"}$9 != 0' ./PCG_panCan327_${end}_all.bed > ./PCG_panCan327_${end}.bed #409/20784

cut -f5 ./PCG_panCan327_${end}.bed > PCG_${end}.txt
cut -f4 ./CGC_in_panCan327_${end}.bed > CGC_${end}.txt