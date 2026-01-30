#!/bin/bash

find /cluster2/home/futing/Project/panCancer/Analysis/ABC/H3K27ac/GEO -type f \
-regextype posix-extended \
  -regex '.*/GSM[0-9]+(\.fastq.gz)$' | cut -f11-13,15 -d '/' | tr '/' '\t' |\
  awk 'BEGIN{FS=OFS="\t"}{split($4, arr, "."); print $1,$2,$3,arr[1]}' > H3K27ac_se0128.txt