#!/bin/bash
cd /cluster/home/futing/Project/GBM/ChIP/CTCF/Johnson_CTCF/G583_standard/macs2
rep1=/cluster/home/futing/Project/GBM/ChIP/CTCF/Johnson_CTCF/G583_standard/macs2/SRR8085199_peaks.narrowPeak
rep2=/cluster/home/futing/Project/GBM/ChIP/CTCF/Johnson_CTCF/G583_standard/macs2/SRR8085200_peaks.narrowPeak
sort -k8,8nr ${rep1} > rep1_sorted.narrowPeak
sort -k8,8nr ${rep2} > rep2_sorted.narrowPeak


idr --samples rep1_sorted.narrowPeak rep2_sorted.narrowPeak \
        --input-file-type narrowPeak \
        --peak-merge-method avg \
        --output-file G583-idr.bed \
        --plot \
        --log-output-file rep1_rep2_idr.log

awk -F '\t' 'BEGIN {FS=OFS="\t"}{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10}' G583-idr.bed > G583_idr_merge.bed        

awk 'BEGIN{OFS="\t"} {print $1, $2, $3, $7}' G583_idr_merge.bed > output.bedGraph
# bedgragh 2 bigwig
LC_ALL=C sort -k1,1 -k2,2n output.bedGraph > sorted_output.bedGraph
bedGraphToBigWig sorted_output.bedGraph /cluster/home/futing/ref_genome/hg38.chrom.sizes G583.bw
