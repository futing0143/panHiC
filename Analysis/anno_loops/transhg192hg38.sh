#!/bin/bash


liftOver <(cut -f1-6 /cluster2/home/futing/Project/panCancer/Analysis/ABC/ATAC/GEO/RCC/GSM2746619_786_control_H3K27ac-SPMR-q05_peaks.narrowPeak) \
/cluster2/home/futing/ref_genome/liftover/hg19ToHg38.over.chain \
/cluster2/home/futing/Project/panCancer/Analysis/ABC/ATAC/GEO/RCC/786O.narrowPeak \
unmapped.bed
