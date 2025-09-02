#!/bin/bash
##01 分别转为.bed文件
while read -r srr; do
    cooler dump --join /cluster/home/tmp/GBM/scHi-C/dipC/${srr}.mcool::resolutions/10000 | \
    awk -v srr_id="$srr" 'BEGIN {OFS="\t"} {print $1, ($2+$3)/2, $4, ($5+$6)/2, $7, srr_id}' > /cluster/home/tmp/GBM/scHi-C/scGAD/input/${srr}.txt
done < srr.list

##02 合并所有 .bed 文件，并添加标题行
cd /cluster/home/tmp/GBM/scHi-C/scGAD/input
echo -e "chrom\tbinA\tbinB\tcount\tcell" > merged_output.bed
awk '$1 == $3 {print $1, $2, $4, $5, $6}' *.txt > temp_merged.bed
cat temp_merged.bed >> merged_output.bed
rm temp_merged.bed
