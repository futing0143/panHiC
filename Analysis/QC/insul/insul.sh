#!/bin/bash
# 2026.1.4
grep -F -w -f <(cut -f1-3 /cluster2/home/futing/Project/panCancer/check/post/insul/insul50k_done0104.txt) \
<(cut -f1-3,7 /cluster2/home/futing/Project/panCancer/check/meta/panCan_annometa.txt) > \
/cluster2/home/futing/Project/panCancer/Analysis/QC/insul/insulmeta0104.txt

python /cluster2/home/futing/Project/panCancer/Analysis/QC/insul/merge.py \
/cluster2/home/futing/Project/panCancer/check/post/insul/insul50k_done0104.txt 6


# 2026.1.4 discarded 旧的合并
cd /cluster2/home/futing/Project/panCancer/QC/insul
output="cancer_327.bed"
>$output

outputmeta="/cluster2/home/futing/Project/panCancer/check/hic/insul0910.txt"
grep 'insul' /cluster2/home/futing/Project/panCancer/check/hic/hicdone0910.txt | cut -f1-3 \
	> $outputmeta
# Extract first 3 columns from first file as base
awk 'BEGIN{OFS="\t"}{print $1,$2,$3}' "/cluster2/home/futing/Project/panCancer/CRC/GSE137188/11-51_Normal/anno/insul/11-51_Normal_5000.tsv" > "$output"
# insul:6, BS: , 
while IFS=$'\t' read -r cancer gse cell ncell; do
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


# awk -F',' 'BEGIN{FS=OFS="\t"}{
#     count[$3]++
#     if (count[$3]==1) {
#         uniq=$3
#     } else {
#         uniq=$3"_"count[$3]
#     }
#     print $0,uniq
# }' ${outputmeta} > tmp && mv tmp ${outputmeta}

# outputmeta="/cluster2/home/futing/Project/panCancer/QC/cancer_meta.txt"
# for cancer in CRC MB TALL; do
#     metafile="/cluster2/home/futing/Project/panCancer/${cancer}/meta/${cancer}_meta.txt"
#     if [ -f "$metafile" ]; then
#         # 去掉表头，并在每行前添加 "$cancer,"
#         awk -v cancer="$cancer" '{print cancer "," $0}' "$metafile" >> "$outputmeta"
#     else
#         echo "Warning: File not found - $metafile" >&2
#     fi
# done



