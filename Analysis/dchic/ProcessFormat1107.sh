#!/bin/bash

# --- futing 2025-11-07 ---
###合并pcOri文件夹下不同染色体的结果，并去掉除了第一行的文字部分
wkdir=/cluster2/home/futing/Project/panCancer/Analysis/dchic/pca/DifferentialResult/NPC/pcOri/
cd ${wkdir}
> "intra_sample_ALL_combined.pcOri_AB.bed"
head -n1 ${wkdir}/intra_sample_chrX_combined.pcOri.bedGraph > intra_sample_ALL_combined.pcOri_AB.bed
ls ${wkdir}/*.bedGraph | \
    xargs -I {} tail -n +2 {} >> tmp
sort -k1,1d -k2,2n -k3,3n tmp >> intra_sample_ALL_combined.pcOri_AB.bed


##提取GBM2NPC的部分 chr	start	end	GBM	*	*>GBM  删掉首行
awk '{print $1"\t"$2"\t"$3"\t"$5"\t"$6"\t"$6">"$5}' intra_sample_ALL_combined.pcOri_AB.bed > NPC2GBM.bed
awk '{print $1"\t"$2"\t"$3"\t"$5"\t"$4"\t"$4">"$5}' intra_sample_ALL_combined.pcOri_AB.bed > pHGG2GBM.bed
awk '{print $1"\t"$2"\t"$3"\t"$5"\t"$7"\t"$7">"$5}' intra_sample_ALL_combined.pcOri_AB.bed > iPSC2GBM.bed

for i in NPC pHGG iPSC
do
intersectBed -a /cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/cgc/G_CGC_tss.bed -b ${i}2GBM_merge.bed -wb |awk '{print $4"\t"$10}' > ${i}2GBM_CGC.bed
intersectBed -a /cluster/home/chenglong/reference/pcg_gene_tss_v38.bed -b ${i}2GBM_merge.bed -wb |awk '{print $7"\t"$15}' > ${i}2GBM_pcg.bed
done
intersectBed -a /cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/cgc/G_CGC_tss.bed \
	-b intra_sample_ALL_combined.pcOri_AB.bed \
	-wb |awk '{print $4"\t"$8"\t"$9"\t"$10"\t"$11}' > ALL_AB_CGC.bed
intersectBed -a /cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/cgc/G_CGC_tss.bed \
	-b intra_sample_ALL_combined.pcOri.bed \
	-wb |awk '{print $4"\t"$8"\t"$9"\t"$10"\t"$11}' > ALL_value_CGC.bed
