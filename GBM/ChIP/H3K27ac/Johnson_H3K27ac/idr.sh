#!/bin/bash
cd /cluster/home/futing/Project/GBM/ChIP/H3K27ac/Johnson_H3K27ac/G523/macs2
name=G523
rep1=/cluster/home/futing/Project/GBM/ChIP/H3K27ac/Johnson_H3K27ac/${name}/macs2/SRR8085202_peaks.narrowPeak
rep2=/cluster/home/futing/Project/GBM/ChIP/H3K27ac/Johnson_H3K27ac/${name}/macs2/SRR8085203_peaks.narrowPeak
sort -k8,8nr ${rep1} > rep1_sorted.narrowPeak
sort -k8,8nr ${rep2} > rep2_sorted.narrowPeak


idr --samples rep1_sorted.narrowPeak rep2_sorted.narrowPeak \
        --input-file-type narrowPeak \
        --peak-merge-method avg \
        --output-file ${name}-idr.bed \
        --plot \
        --log-output-file rep1_rep2_idr.log

awk -F '\t' 'BEGIN {FS=OFS="\t"}{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10}' ${name}-idr.bed > ${name}_idr_merge.bed        

awk 'BEGIN{OFS="\t"} {print $1, $2, $3, $7}' ${name}_idr_merge.bed > output.bedGraph
# bedgragh 2 bigwigno
LC_ALL=C sort -k1,1 -k2,2n output.bedGraph > sorted_output.bedGraph
bedGraphToBigWig sorted_output.bedGraph /cluster/home/futing/ref_genome/hg38.chrom.sizes ${name}_H3K27ac.bw
