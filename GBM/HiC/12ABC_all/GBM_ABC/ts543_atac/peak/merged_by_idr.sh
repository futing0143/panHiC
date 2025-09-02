#!/bin/bash

cd /cluster/home/futing/Project/GBM/HiC/12ABC_all/GBM_ABC/ts543_atac/peak
rep1=/cluster/home/futing/Project/GBM/HiC/12ABC_all/GBM_ABC/ts543_atac/peak/atac_rep1_peaks.narrowPeak
rep2=/cluster/home/futing/Project/GBM/HiC/12ABC_all/GBM_ABC/ts543_atac/peak/atac_rep2_peaks.narrowPeak

# IDR

sort -k8,8nr ${rep1} > rep1_sorted.narrowPeak
sort -k8,8nr ${rep2} > rep2_sorted.narrowPeak


idr --samples rep1_sorted.narrowPeak rep2_sorted.narrowPeak \
        --input-file-type narrowPeak \
        --peak-merge-method avg \
        --output-file ATAC_idr.bed \
        --plot \
        --log-output-file rep1_rep2_idr.log

# 取所有merged不筛选的结果
awk -F '\t' 'BEGIN {FS=OFS="\t"}{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10}' ATAC_idr.bed > ATAC_idr_merge.bed   