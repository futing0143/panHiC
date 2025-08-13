#!/bin/bash

cd /cluster/home/futing/Project/GBM/CTCF/GSE121601/G567/macs2
rep1=/cluster/home/futing/Project/GBM/CTCF/GBM/Johnson/G567/macs2/SRR8085196_peaks.narrowPeak
rep2=/cluster/home/futing/Project/GBM/CTCF/GBM/Johnson/G567/macs2/SRR8085197_peaks.narrowPeak

# IDR

sort -k8,8nr ${rep1} > rep1_sorted.narrowPeak
sort -k8,8nr ${rep2} > rep2_sorted.narrowPeak


idr --samples rep1_sorted.narrowPeak rep2_sorted.narrowPeak \
        --input-file-type narrowPeak \
        --peak-merge-method avg \
        --output-file G567-idr2.bed \
        --plot \
        --log-output-file rep1_rep2_idr.log

awk -F '\t' 'BEGIN {FS=OFS="\t"}{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10}' G567-idr2.bed > G567_idr_merge.bed        
# 方法2 输出A在B中有overlap 50%以上的peak + 重复长度    
bedtools intersect -a ${rep1} -b ${rep2} -f 0.5 -r -wo > G567_wo.bed

# 方法3 -wa -wb 输出A和B的peak + 重复长度
bedtools intersect -a SRR8085197_peaks.narrowPeak -b SRR8085196_peaks.narrowPeak -f 0.5 -r -wa -wb > G567_all.bed
#awk -F '\t' 'BEGIN {FS=OFS="\t"}{print $3,$4,$2,$5,$6}'

# 方法4  -wao
# 加了-f 0.5 -r 之后，和A行数一样，不加比A多
bedtools intersect -a ${rep1} -b ${rep2} -f 0.5 -r -wao > G567_wao.bed
awk 'BEGIN {FS=OFS="\t"}NF{NF-=1};1' /cluster/home/futing/Project/GBM/CTCF/GBM/Johnson/G567/macs2/G567_wao.bed >G567_wao_1.bed


# 方法5 压扁
cd /cluster/home/futing/Project/GBM/CTCF/GSE121601/G567/macs2
cat SRR8085196_peaks.narrowPeak SRR8085197_peaks.narrowPeak > G567.merge.narrowPeak
bedtools sort -faidx /cluster/share/ref_genome/hg38/assembly/hg38.chrom.sizes -i G567.merge.narrowPeak > G567.merge.narrowPeak.sorted
bedtools merge -i G567.merge.narrowPeak.sorted > G567.merge.narrowPeak.sorted.merged




# 查看 -wao 的前三列为什么比原来的多
awk -F '\t' 'BEGIN {FS=OFS="\t"}{print $1,$2,$3}' G567_wao_1.bed > G567_wao_top3.bed
awk -F '\t' 'BEGIN {FS=OFS="\t"}{print $1,$2,$3}' /cluster/home/futing/Project/GBM/CTCF/GBM/Johnson/G567/macs2/SRR8085196_peaks.narrowPeak > G567_rep1_top3.bed    