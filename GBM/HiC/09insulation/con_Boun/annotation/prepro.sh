#!/bin/bash
# preprocess gencode annotation
RNA=/cluster/home/futing/ref_genome/hg38_gencode/humanGTF

grep -w 'protein_coding' /cluster/home/futing/Project/GBM/HiC/09insulation/con_Boun/annotation/gencode.bed \
    | awk 'BEGIN{OFS=FS="\t"}{print $1, ($2 > 0 ? $2-501 : 0),$2+500,$6,$4}' \
    > CGC_500ud.bed
awk 'BEGIN {OFS="\t"} {split($4, a, "."); $4 = a[1]; print}' CGC_500ud.bed > CGC_tss_500ud.bed
sort -k4 CGC_tss_500ud.bed > CGC_tss_500ud_s.bed && mv CGC_tss_500ud_s.bed CGC_tss_500ud.bed

awk 'BEGIN{OFS=FS="\t"}{print $4,$5,$6,$1,$2,$3}' $RNA > \
    /cluster/home/futing/Project/GBM/HiC/09insulation/insul_futing/conserve_B/gencode.bed
awk 'BEGIN{OFS=FS="\t"}{print $4, ($5 > 0 ? $5-1 : 0),$5,$1,$2,$3}' $RNA > \
    /cluster/home/futing/Project/GBM/HiC/09insulation/insul_futing/conserve_B/gencode_tss.bed