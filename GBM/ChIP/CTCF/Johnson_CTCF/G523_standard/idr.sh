#!/bin/bash
cd /cluster/home/futing/Project/GBM/ChIP/CTCF/Johnson_CTCF/G523_standard/macs2
rep1=/cluster/home/futing/Project/GBM/ChIP/CTCF/Johnson_CTCF/G523_standard/macs2/SRR8085193_peaks.narrowPeak
rep2=/cluster/home/futing/Project/GBM/ChIP/CTCF/Johnson_CTCF/G523_standard/macs2/SRR8085194_peaks.narrowPeak
sort -k8,8nr ${rep1} > rep1_sorted.narrowPeak
sort -k8,8nr ${rep2} > rep2_sorted.narrowPeak


idr --samples rep1_sorted.narrowPeak rep2_sorted.narrowPeak \
        --input-file-type narrowPeak \
        --peak-merge-method avg \
        --output-file G523-idr.bed \
        --plot \
        --log-output-file rep1_rep2_idr.log

awk -F '\t' 'BEGIN {FS=OFS="\t"}{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10}' G523-idr.bed > G523_idr_merge.bed        

awk 'BEGIN{OFS="\t"} {print $1, $2, $3, $7}' G523_idr_merge.bed > output.bedGraph
# bedgragh 2 bigwig
bedGraphToBigWig output.bedGraph /cluster/home/futing/ref_genome/hg38.chrom.sizes G523.bw
