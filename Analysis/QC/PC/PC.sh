#!/bin/bash
d=0104


cd /cluster2/home/futing/Project/panCancer/Analysis/QC/PC


# outputmeta="/cluster2/home/futing/Project/panCancer/QC/cancer_meta.txt"
# 检查 PC 100k 完成
# input=/cluster2/home/futing/Project/panCancer/check/done_meta.txt
# undonefile=/cluster2/home/futing/Project/panCancer/check/post/PCundone0918.txt
annometa=/cluster2/home/futing/Project/panCancer/check/meta/panCan_annometa.txt
outputmeta="/cluster2/home/futing/Project/panCancer/Analysis/QC/PC/PC${d}.txt"
>$outputmeta


# 直接从post中找
awk 'BEGIN{FS=OFS="\t"}{if ($4=="PC"){
print $1,$2,$3}
}' /cluster2/home/futing/Project/panCancer/check/post/all/hicdone${d}.txt \
| sort -u -k1 -k2 -k3 \
> ${outputmeta}
awk 'NR==FNR{
    key=$1"\t"$2"\t"$3     # 前三列作为 key
    val[key]=$(NF-1)           # 保存 file2 的最后一列
    next
}
{
    key=$1"\t"$2"\t"$3
    print $0"\t"val[key]   # 输出 file1 + file2 最后一列
}' ${annometa} ${outputmeta} | sort -k1 -k2 -k3 -u > tmp && mv tmp ${outputmeta}

python /cluster2/home/futing/Project/panCancer/Analysis/QC/PC/merge.py $outputmeta 5

# awk -F',' 'BEGIN{FS=OFS="\t"}{
#     count[$3]++
#     if (count[$3]==1) {
#         uniq=$3
#     } else {
#         uniq=$3"_"count[$3]
#     }
#     print $0,uniq
# }' ${outputmeta} > tmp && mv tmp ${outputmeta}

# --------------------------
# output="cancer_327.bed"
# >$output
# Extract first 3 columns from first file as base
# awk 'BEGIN{OFS="\t"}{print $1,$2,$3}' "/cluster2/home/futing/Project/panCancer/CRC/GSE137188/11-51_Normal/anno/insul/11-51_Normal_5000.tsv" > "$output"
# # insul:6, BS: , 
# while IFS=$'\t' read -r cancer gse cell ncell; do
#     file="/cluster2/home/futing/Project/panCancer/${cancer}/$gse/$cell/anno/insul/${cell}_5000.tsv"
    
#     if [ -f "$file" ]; then
#         # Extract 6th column with cell name as header
#         awk -v cell="${ncell}" 'BEGIN{OFS="\t"} NR==1 {print cell} NR>1 {print $6}' "$file" > tmp_col
        
#         # Paste with output file
#         paste "$output" tmp_col > tmp_merged
#         mv tmp_merged "$output"
#         rm tmp_col
#     else
#         echo "File not found: $file" >&2
#     fi
# done < $outputmeta

