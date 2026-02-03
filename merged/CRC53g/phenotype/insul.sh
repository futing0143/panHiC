#!/bin/bash


cd /cluster2/home/futing/Project/HiCQTL/merged/CRC53
output="/cluster2/home/futing/Project/HiCQTL/merged/CRC53/phenotype/CRC53.bed"
>$output
# Extract first 3 columns from first file as base
awk 'BEGIN{OFS="\t"}{print $1,$2,$3}' "/cluster2/home/futing/Project/panCancer/CRC/GSE137188/11-51_Normal/anno/insul/11-51_Normal_5000.tsv" > "$output"

while IFS=$' ' read -r gse cell other; do
    file="/cluster2/home/futing/Project/panCancer/CRC/$gse/$cell/anno/insul/${cell}_5000.tsv"
    
    if [ -f "$file" ]; then
        # Extract 6th column with cell name as header
        awk -v cell="$cell" 'BEGIN{OFS="\t"} NR==1 {print cell} NR>1 {print $6}' "$file" > tmp_col
        
        # Paste with output file
        paste "$output" tmp_col > tmp_merged
        mv tmp_merged "$output"
        rm tmp_col
    else
        echo "File not found: $file" >&2
    fi
done < '/cluster2/home/futing/Project/HiCQTL/merged/CRC53/CRC_meta.txt'

echo "Merged file saved to: $output"


# clipperQTL preprocessing
# 没必要

cut -f4- /cluster2/home/futing/Project/HiCQTL/merged/CRC53/phenotype/CRC53_Aug15.bed > /cluster2/home/futing/Project/HiCQTL/merged/CRC53/phenotype/CRC53_Aug30.bed
