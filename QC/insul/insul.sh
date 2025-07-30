#!/bin/bash


cd /cluster2/home/futing/Project/panCancer/QC
output="cancer_Jun26.bed"
outputmeta="/cluster2/home/futing/Project/panCancer/QC/cancer_meta.txt"
>$output
# > "$outputmeta"

# for cancer in CRC MB TALL; do
#     metafile="/cluster2/home/futing/Project/panCancer/${cancer}/meta/${cancer}_meta.txt"
#     if [ -f "$metafile" ]; then
#         # 去掉表头，并在每行前添加 "$cancer,"
#         awk -v cancer="$cancer" '{print cancer "," $0}' "$metafile" >> "$outputmeta"
#     else
#         echo "Warning: File not found - $metafile" >&2
#     fi
# done

# Extract first 3 columns from first file as base
awk 'BEGIN{OFS="\t"}{print $1,$2,$3}' "/cluster2/home/futing/Project/panCancer/CRC/GSE137188/11-51_Normal/anno/insul/11-51_Normal_5000.tsv" > "$output"

while IFS=$',' read -r cancer gse cell other; do
    file="/cluster2/home/futing/Project/panCancer/${cancer}/$gse/$cell/anno/insul/${cell}_5000.tsv"
    
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
done < $outputmeta

