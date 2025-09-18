#!/bin/bash

cd /cluster2/home/futing/Project/panCancer/Analysis/conserve
annodir=/cluster2/home/futing/Project/panCancer/GBM/HiC/09insulation/con_Boun/annotation/

bedtools intersect -a ${annodir}/Census_tss.bed \
	-b <(cut -f1-3 ./panCan327_5k15k.bed) \
	-wao > ./CGC_in_panCan327_5k15k.bed