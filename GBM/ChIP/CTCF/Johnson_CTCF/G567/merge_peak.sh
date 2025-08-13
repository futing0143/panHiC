#!/bin/bash
cd /cluster/home/futing/Project/GBM/CTCF/GSE121601/G567/macs2
cat SRR8085196_peaks.narrowPeak SRR8085197_peaks.narrowPeak > G567.merge.narrowPeak
bedtools sort -faidx /cluster/share/ref_genome/hg38/assembly/hg38.chrom.sizes -i G567.merge.narrowPeak > G567.merge.narrowPeak.sorted
bedtools merge -i G567.merge.narrowPeak.sorted > G567.merge.narrowPeak.sorted.merged

# 方法2
bedtools intersect -a SRR8085197_peaks.narrowPeak -b SRR8085196_peaks.narrowPeak -wa -wb > G567_all.bed
awk -F '\t' 'BEGIN {FS=OFS="\t"}{print $3,$4,$2,$5,$6}'