#!/bin/bash

h3k27ac_bed=/cluster/home/futing/Project/GBM/HiC/12ABC_all/GBM_ABC/ts543_h3k27ac/macs2/SRR12056338_peaks.narrowPeak
atac_bed=/cluster/home/futing/Project/GBM/HiC/12ABC_all/GBM_ABC/ts543_atac/peak/ATAC_idr_merge.bed
ctcf_bed=/cluster/home/futing/Project/GBM/CTCF/GSE121601/G567/macs2/G567_idr_merge.bed

# 拓展SNP上下区域
sort /cluster/home/futing/Project/GBM/eqtl/pancanQTL/gbm_eqtls_hg38.bed | uniq | awk '{printf "%s\t%s\t%s\t%s\n", $1, ($2-5 > 0 ? $2-5 : 0), ($3+5), sprintf("%s_%s_%s", $1, $2, $3)}' ${gbm_eqtls_hg38} > ./gbm_left_join/gbm_eqtls_extend.bed
eqtl_dt=./gbm_left_join/gbm_eqtls_extend.bed

for feature in h3k27ac atac ctcf;do
    bed_file=${feature}_bed
    # 使用 eval 解析变量值
    bed_file_path=$(eval echo \${$bed_file})
    echo -e "Processing ${bed_file_path}..."

    #intersect eQTLs with peaks
    bedtools intersect -a $eqtl_dt -b $bed_file_path -loj > ./gbm_left_join/${feature}_gbm.bed
    # keep intersection with peaks
    awk -F '\t' 'BEGIN {FS=OFS="\t"}{print $1,$2,$3,$11,$1"_"$2"_"$3 }' ./gbm_left_join/${feature}_gbm.bed > ./gbm_left_join/${feature}_gbm.bed.tmp
    mv ./gbm_left_join/${feature}_gbm.bed.tmp ./gbm_left_join/${feature}_gbm.bed
done

# 组合
find /cluster/home/futing/Project/GBM/eqtl/gbm_left_join/ -name "*_gbm.bed" | while read -r f ; do
    if [ -s $f ];then
        name=$(basename "$f" _gbm.bed)
        echo -e 'Processing ${name}..'
        awk '{FS=OFS="\t"}{if ($4 == ".") {print $5, 0, 0} else {print $5, $4, 1}}' "$f" | sort -k1,1 | uniq > ./gbm_left_join/combined.tmp
        mv ./gbm_left_join/combined.tmp ./gbm_left_join/${name}.tsv
    fi 
done

join -t $'\t' -1 1 -2 1 -o "1.1,1.2,1.3,2.2,2.3" ./gbm_left_join/h3k27ac.tsv ./gbm_left_join/atac.tsv | sort -k1,1 > gbm_combined.bed
join -t $'\t' -1 1 -2 1 -o "1.1,1.2,1.3,1.4,1.5,2.2,2.3" gbm_combined.bed ./gbm_left_join/ctcf.tsv | sort -k1,1 > gbm_combined.tmp
mv gbm_combined.tmp gbm_combined.bed
echo -e "chr_start_end\th3k27ac\th3k27ac_signal\tatac\tatac_signal\tctcf\tctcf_signal" > ./gbm_left_join/gbm_combined.bed
awk -F'\t' '{FS=OFS="\t"}{print $1,$2,$3,$4,$5,$6,$7}' gbm_combined.bed >> ./gbm_left_join/gbm_combined.bed

# atac有多少非0
#awk -F '\t' '$4 != "0"' ./gbm_left_join/gbm_combined.bed | wc -l
#awk -F '\t' '$4 != "."' /cluster/home/futing/Project/GBM/eqtl/gbm_left_join/atac_gbm.bed | wc -l