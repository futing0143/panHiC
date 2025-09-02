#!/bin/bash
#eqtls_dt=/cluster/home/futing/Project/GBM/eqtl/pancanQTL/gbm_eqtls_hg38.bed

h3k27ac_bed=/cluster/home/futing/Project/GBM/HiC/12ABC_all/GBM_ABC/ts543_h3k27ac/macs2/SRR12056338_peaks.narrowPeak
atac_bed=/cluster/home/futing/Project/GBM/HiC/12ABC_all/GBM_ABC/ts543_atac/peak/ATAC_idr_merge.bed
ctcf_bed=/cluster/home/futing/Project/GBM/CTCF/GSE121601/G567/macs2/G567_idr_merge.bed
FC={1:0}
pvalue={2:0.05}

sort /cluster/home/futing/Project/GBM/eqtl/blood_eqtls.bed | uniq > ./blood_left_join/blood_eqtls_uniq.bed
eqtl_dt=./blood_left_join/blood_eqtls_uniq.bed
for feature in h3k27ac atac ctcf;do
    bed_file="${feature}_bed"
    bed_file_path="${!bed_file}"

    echo -e "Processing ${bed_file_path}..."
    # filter peaks 做不到因为没有pvalue
    #cat $bed_file_path | sort -k1,1 -k2,2n | \
	#awk -v FC="$FC" -v pvalue="$pvalue" 'BEGIN{FS="\t"} $7 >= FC && $8 >= pvalue' > filtered.peaks

    #intersect eQTLs with peaks
    bedtools intersect -a $eqtl_dt -b $bed_file_path -loj > ./blood_left_join/${feature}_blood.bed
    # keep intersection with peaks
    awk -F '\t' 'BEGIN {FS=OFS="\t"}{print $1,$2,$3,$10,$1"_"$2"_"$3 }' ./blood_left_join/${feature}_blood.bed > ./blood_left_join/${feature}_blood.bed.tmp
    mv ./blood_left_join/${feature}_blood.bed.tmp ./blood_left_join/${feature}_blood.bed
done


