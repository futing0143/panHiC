#!/bin/bash


find /cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO \
-type f -regextype posix-extended -regex '.*/GSM[0-9]+(\.fastq.gz)$' | cut -f11,13 -d '/' | tr '/' '\t' | \
awk 'BEGIN{FS=OFS="\t"}{split($2, arr, "."); print $1,arr[1]}' > RNAcancerlist_se.txt

# RNAse的脚本是有问题的，会将所有的视为single-en并且只去掉R1部分

while read -r gsm;do
rm -r /cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/DLBCL/