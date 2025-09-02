#!/bin/bash

name=A172
concen=/cluster/home/futing/Project/GBM/HiC/10loop/consensus/mid/${name}/${name}_merged2.bed
cooldots=/cluster/home/futing/Project/GBM/HiC/10loop/cooltools/results/${name}/dots.10000.tsv
fithic=/cluster/home/futing/Project/GBM/HiC/10loop/fithic/outputs/10000/${name}.intraOnly/${name}.merge.bed.gz
hiccups=/cluster/home/futing/Project/GBM/HiC/10loop/hiccups/results/${name}/merged_loops.bedpe
homer=/cluster/home/futing/Project/GBM/HiC/10loop/homer/results/${name}/10000/${name}.loop.2D.bed
peakachu=/cluster/home/futing/Project/GBM/HiC/10loop/peakachu/10000/results/${name}-peakachu-10kb-loops.0.95.bedpe
mustache=/cluster/home/futing/Project/GBM/HiC/10loop/mustache/10000/${name}_10kb_mustache.bedpe
TADfile=/cluster/home/futing/Project/GBM/HiC/08TAD/OnTAD/10000/A172/A172_2.bed


mkdir -p /cluster/home/futing/Project/GBM/HiC/UCSC/${name}/loop
reso_half=5000
awk -v reso=$reso_half 'BEGIN{OFS="\t"}{print $1, $2-reso, $2+reso,$1,$3-reso,$3+reso}' \
    $concen > /cluster/home/futing/Project/GBM/HiC/UCSC/${name}/loop/${name}_concen.bedpe
awk 'BEGIN{OFS="\t"}
    NR == 1 {print "#chrom1","start1","end1","chrom2","start2","end2","CC","qval"} 
    NR > 1 {print $1, $2, $3,$4,$5,$6,$7,$12}' \
    $cooldots > /cluster/home/futing/Project/GBM/HiC/UCSC/${name}/loop/${name}_cooldots.bedpe
zcat $fithic | awk -v reso=$reso_half 'BEGIN{OFS="\t"}
    NR==1{print "#"$1,"start","end",$3,"start","end","CC","p","fdr"}
    NR>1{print $1, $2-reso, $2+reso,$3,$4-reso,$4+reso,$5,$6,$7}' \
    > /cluster/home/futing/Project/GBM/HiC/UCSC/${name}/loop/${name}_fithic.bedpe

cp $hiccups /cluster/home/futing/Project/GBM/HiC/UCSC/${name}/loop/${name}_hiccups.bedpe
cp $homer /cluster/home/futing/Project/GBM/HiC/UCSC/${name}/loop/${name}_homer.bedpe
cp $peakachu /cluster/home/futing/Project/GBM/HiC/UCSC/${name}/loop/${name}_peakachu.bedpe
cp $mustache /cluster/home/futing/Project/GBM/HiC/UCSC/${name}/loop/${name}_mustache.bedpe
