#!/bin/bash
cd /cluster/home/futing/Project/GBM/RNA/20240830

# 算 gene-TPM_matrix.txt 的均值

file_list=()
metadata_file="metadata.tsv"

while read -r file; do
    echo "Processing $file..."
    file_list+=("$file")
    # name=$(basename "$file" .genes.results)
    # # 提取 rsem_out 上一级目录名
    # group=$(echo "$file" | awk -F'/' '{print $(NF-3)}')
    # echo -e "$name\t$group\t$file" >> "$metadata_file"
done < <(find -L /cluster/home/futing/Project/GBM/RNA -name '*genes.results')

sh /cluster/home/futing/Project/GBM/RNA/count.sh "${file_list[@]}"


# ---- 算所有 gene-TPM-matrix.txt 的平均值
find -L /cluster/home/futing/Project/GBM/RNA -name 'gene-TPM-matrix.txt' | while read -r file; do
    echo "Processing $file..."
    dirn=$(dirname "$file" | cut -d'/' -f8)

    cd /cluster/home/futing/Project/GBM/RNA/$dirn
    python /cluster/home/futing/Project/GBM/RNA/preprocess.py $file $dirn

done
python /cluster/home/futing/Project/GBM/RNA/preprocess.py \
    /cluster/home/futing/Project/GBM/RNA/pHGG/gene-TPM-matrix_pGBM.txt pHGG
python /cluster/home/futing/Project/GBM/RNA/preprocess.py \
    /cluster/home/futing/Project/GBM/RNA/NPC/gene-count-matrix_NPC.txt NPC
python /cluster/home/futing/Project/GBM/RNA/preprocess.py \
    /cluster/home/futing/Project/GBM/RNA/iPSC/gene-TPM-matrix_WTC.txt iPSC
python /cluster/home/futing/Project/GBM/RNA/preprocess.py \
    /cluster/home/futing/Project/GBM/RNA/GBM/gene-TPM-matrix_gbm.txt ts543



# /cluster/home/futing/Project/GBM/HiC/09insulation/con_Boun/annotation/CGC_tss_500ud.bed

find -L /cluster/home/futing/Project/GBM/RNA -name '*_mean.bed' | while read -r file; do
    echo "Processing $file..."
    name=$(basename "$file" _mean.bed)
    #mv ${name}.bam ./${name}
    awk 'BEGIN {OFS="\t"} {split($1, a, "."); $1 = a[1]; print}' $file \
		> ./${name}/${name}_mean_nodot.bed

    join -1 1 -2 4 -o 2.1 2.2 2.3 2.4 1.2 ./${name}/${name}_mean_nodot.bed CGC_tss_500ud.bed > ./${name}/${name}_CGC500.bed

done