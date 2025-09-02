#!/bin/bash
# 这段代码的目的整合有peak的eqtl到原始
eqtls_dt=/cluster/home/futing/Project/GBM/eqtl/blood_eqtls.bed
bed="/cluster/home/futing/Project/GBM/eqtl/beds/ts543_h3k27ac.bed /cluster/home/futing/Project/GBM/eqtl/beds/g567_ctcf.bed /cluster/home/futing/Project/GBM/eqtl/beds/atac_ts543.bed"
for assay in h3k27ac atac ctcf; do
    # 第一列 合并的chr_start_end
    awk 'BEGIN{FS="\t";OFS="_"}{print $1,$2,$3}' $eqtls_dt > ${assay}.tsv

    for f in ${bed}; do
    if [ -s $f ];
    then
        /cluster/home/futing/Project/GBM/eqtl/transferQTL/bin/join3.py -b ${assay}.tsv -a <(awk '{print $0"\t"1}' $f) -u -p 0 > ${assay}.tmp;
        mv ${assay}.tmp ${assay}.tsv
    fi 
    done
    #判断从第2列到最后一列是否有任何一个值大于 0。如果有，则输出该行的第一列和一个 1；如果没有，则输出该行的第一列和一个 0
    awk 'BEGIN{FS=OFS="\t"}{n=0; for (i=2;i<=NF;i++){if ($i>0){n+=1}}; if (n>0){print $1, 1} else {print $1, 0}}' ${assay}.tsv > ${assay}.tmp
    #mv ${assay}.tmp ${assay}.tsv
done