#!/bin/bash

# 2026.1.2 
python /cluster2/home/futing/Project/panCancer/Analysis/conserve/merge.py \
/cluster2/home/futing/Project/panCancer/check/post/insul/insul50k_done0104.txt 8

# 2026.1.2 legency
cd /cluster2/home/futing/Project/panCancer/Analysis/conserve
output="cancer_412.bed"
>$output

outputmeta="/cluster2/home/futing/Project/panCancer/Analysis/conserve/insul50k_${d}.txt"

# Extract first 3 columns from first file as base
awk 'BEGIN{OFS="\t"}{print $1,$2,$3}' "/cluster2/home/futing/Project/panCancer/CRC/GSE137188/11-51_Normal/anno/insul/11-51_Normal_5000.tsv" > "$output"
# insul:6, BS:8 
while IFS=$'\t' read -r cancer gse cell clcell ncell; do
    file="/cluster2/home/futing/Project/panCancer/${cancer}/$gse/$cell/anno/insul/${cell}_5000.tsv"
    
    if [ -f "$file" ]; then
        # Extract 6th column with cell name as header
        awk -v cell="${ncell}" 'BEGIN{OFS="\t"} NR==1 {print cell} NR>1 {print $6}' "$file" > tmp_col
        
        # Paste with output file
        paste "$output" tmp_col > tmp_merged
        mv tmp_merged "$output"
        rm tmp_col
    else
        echo "File not found: $file" >&2
    fi
done < $outputmeta

