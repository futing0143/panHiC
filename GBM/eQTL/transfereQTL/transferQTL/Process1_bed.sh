#!/bin/bash
#eqtls_dt=/cluster/home/futing/Project/GBM/eqtl/pancanQTL/gbm_eqtls_hg38.bed
eqtl_dt=./blood_left_join/blood_eqtls_uniq.bed
h3k27ac_bed=/cluster/home/futing/Project/GBM/HiC/12ABC_all/GBM_ABC/ts543_h3k27ac/macs2/SRR12056338_peaks.narrowPeak
atac_bed=/cluster/home/futing/Project/GBM/HiC/12ABC_all/GBM_ABC/ts543_atac/peak/ATAC_idr_merge.bed
ctcf_bed=/cluster/home/futing/Project/GBM/CTCF/GSE121601/G567/macs2/G567_idr_merge.bed

for feature in h3k27ac atac ctcf;do
# bedtools intersect 
    file_id="${feature}_blood"
    bed_file="${feature}_bed"
    # 使用 eval 解析变量值
    bed_file_path=$(eval echo \${$bed_file})
    #bed_file_path="${!bed_file}"
    echo "Processing ${bed_file_path}.."
    /cluster/home/futing/Project/GBM/eqtl/transferQTL/bin/intersect.peaks.regions.sh --regions $eqtls_dt \
        --peaks ${bed_file_path} \
        --ext 'bed' --outFolder ./blood_wao/ \
        --outFile ${file_id}.bed

    # keep only eQTLs with an intersection
    awk '$NF>0{print $1"_"$2"_"$3}' ./blood_wao/${file_id}.bed | sort -u > ./blood_wao/${file_id}.bed.tmp 
    mv ./blood_wao/${file_id}.bed.tmp ./blood_wao/${file_id}_pos.bed
done
