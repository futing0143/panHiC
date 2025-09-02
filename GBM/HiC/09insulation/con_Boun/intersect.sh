#!/bin/bash
# preprocess gencode annotation
grep -w 'protein_coding' /cluster/home/futing/Project/GBM/HiC/09insulation/con_Boun/annotation/gencode.bed \
    | awk 'BEGIN{OFS=FS="\t"}{print $1, ($2 > 0 ? $2-501 : 0),$2+500,$6,$4}' \
    > CGC_500ud.bed
awk 'BEGIN {OFS="\t"} {split($4, a, "."); $4 = a[1]; print}' CGC_500ud.bed > CGC_tss_500ud.bed
sort -k4 CGC_tss_500ud.bed > CGC_tss_500ud_s.bed && mv CGC_tss_500ud_s.bed CGC_tss_500ud.bed

awk 'BEGIN{OFS=FS="\t"}{print $4,$5,$6,$1,$2,$3}' $RNA > \
    /cluster/home/futing/Project/GBM/HiC/09insulation/insul_futing/conserve_B/gencode.bed
awk 'BEGIN{OFS=FS="\t"}{print $4, ($5 > 0 ? $5-1 : 0),$5,$1,$2,$3}' $RNA > \
    /cluster/home/futing/Project/GBM/HiC/09insulation/insul_futing/conserve_B/gencode_tss.bed

# find conserve boundaries that overlap with gene TSS
RNA=/cluster/home/futing/ref_genome/hg38_gencode/humanGTF
boundary=/cluster/home/futing/Project/GBM/HiC/09insulation/insul_futing/conserve_B/10K_50k_cb.bed
gencode=/cluster/home/futing/Project/GBM/HiC/09insulation/insul_futing/conserve_B/gencode.bed
bedtools intersect -a $boundary -b $gencode -wao > /cluster/home/futing/Project/GBM/HiC/09insulation/insul_futing/conserve_B/intersect.bed


# Process the Census data
cd /cluster/home/futing/Project/GBM/HiC/09insulation/insul_futing/conserve_B/annotation
CGC=/cluster/home/futing/ref_genome/Cosmic_CancerGeneCensus_Tsv_v100_GRCh38/Cosmic_CancerGeneCensus_v100_GRCh38.tsv
awk 'BEGIN{FS=OFS="\t"} NR>1{print "chr" $4, $5-1, $6, $1, $10, $15}' $CGC > census.tmp
awk 'BEGIN{FS=OFS="\t"} ($2 != "-1") {if ($5 == "") $5 = "otherCGC"; print $0}' census.tmp | sort -k1,1V -k2,2n -k3,3n > Census.bed
awk 'BEGIN{FS=OFS="\t"}{print $1, ($2 > 0 ? $2-1 : 0),$2,$4,$5,$6}' Census.bed > Census_tss.bed
#cut -f1,2,3 /cluster/home/futing/Project/GBM/HiC/09insulation/insul_futing/10k_50k/42MGBA_insul.tsv > bins.bed


# find num of CGC in conserve boundaries
bedtools intersect -a Census_tss.bed -b ../10K_50k_cb.bed -wao > /cluster/home/futing/Project/GBM/HiC/09insulation/insul_futing/conserve_B/CGC_inbound_all.bed
awk 'BEGIN{FS=OFS="\t"}$10 ==1' ../CGC_inbound_all.bed > ../CGC_inbound.bed #111/742
grep -Ei 'glioma|GBM|glioblastoma|other' ../CGC_inbound_all.bed > ../GBM_inbound_all.bed
awk 'BEGIN{FS=OFS="\t"}$10 ==1' ../GBM_inbound_all.bed > ../GBM_inbound.bed # 21/99

# find the num of CGC in GBM boundaries
bedtools intersect -a /cluster/home/futing/Project/GBM/HiC/09insulation/con_Boun/annotation/Census_tss.bed \
    -b /cluster/home/futing/Project/GBM/HiC/09insulation/con_Boun/GBM/10K_50k_not_conserve.bed \
    -wao > /cluster/home/futing/Project/GBM/HiC/09insulation/con_Boun/GBM/CGC_notcon_all.bed
awk 'BEGIN{FS=OFS="\t"}$10 ==1' ./GBM/CGC_notcon_all.bed > ./GBM/CGC_notcon.bed  # 603/742
grep -Ei 'glioma|GBM|glioblastoma|other' ./GBM/CGC_notcon.bed > ./GBM/GBM_notcon_all.bed 
awk 'BEGIN{FS=OFS="\t"}$10 ==1' ./GBM/GBM_notcon_all.bed > ./GBM/GBM_notcon.bed # 72/72

# find the num of CGC in NPC boundaries
awk 'BEGIN{FS=OFS="\t"} $9 =="True"' /cluster/home/futing/Project/GBM/HiC/09insulation/insul_futing/10k_50k/NPC_new_insul.tsv | cut -f1,2,3 > NPC_boundary.bed
bedtools intersect -a ./annotation/Census_tss.bed -b ./NPC/NPC_boundary.bed -wao > /cluster/home/futing/Project/GBM/HiC/09insulation/insul_futing/conserve_B/NPC/CGC_NPC_all.bed
awk 'BEGIN{FS=OFS="\t"}$10 ==1' ./NPC/CGC_NPC_all.bed > ./NPC/CGC_NPC.bed # 61/742
grep -Ei 'glioma|GBM|glioblastoma|other' ./NPC/CGC_NPC_all.bed > ./NPC/NPC_inbound_all.bed
awk 'BEGIN{FS=OFS="\t"}$10 ==1' ./NPC/NPC_inbound_all.bed > ./NPC/NPC_inbound.bed # 4/99


# find the num of CGC in iPSC boundaries
awk 'BEGIN{FS=OFS="\t"} $9 =="True"' /cluster/home/futing/Project/GBM/HiC/09insulation/insul_futing/10k_50k/iPSC_new_insul.tsv | cut -f1,2,3 > ./iPSC/iPSC_boundary.bed
bedtools intersect -a ./annotation/Census_tss.bed -b ./iPSC/iPSC_boundary.bed -wao > /cluster/home/futing/Project/GBM/HiC/09insulation/insul_futing/conserve_B/iPSC/CGC_iPSC_all.bed
awk 'BEGIN{FS=OFS="\t"}$10 ==1' ./iPSC/CGC_iPSC_all.bed > ./iPSC/CGC_iPSC.bed # 78/742
grep -Ei 'glioma|GBM|glioblastoma|other' ./iPSC/CGC_iPSC_all.bed > ./iPSC/iPSC_inbound_all.bed
awk 'BEGIN{FS=OFS="\t"}$10 ==1' ./iPSC/iPSC_inbound_all.bed > ./iPSC/iPSC_inbound.bed # 12/99

