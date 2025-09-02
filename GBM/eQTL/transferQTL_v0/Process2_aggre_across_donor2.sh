#!/bin/bash

eqtls_dt=./blood_left_join/blood_eqtls_uniq.bed

#awk 'BEGIN{FS="\t";OFS="_"}{print $1,$2,$3}' $eqtls_dt > ./Process2/combined.tsv

find /cluster/home/futing/Project/GBM/eqtl/blood_left_join/ -name "*_blood.bed" | while read -r f ; do
    if [ -s $f ];then
        name=$(basename $f _blood.bed)
        echo -e 'Processing ${name}..'
        awk '{FS=OFS="\t"}{if ($4 == ".") {print $5, 0, 0} else {print $5, $4, 1}}' "$f" | sort -k1,1 | uniq > ./Process2/combined.tmp
        mv ./Process2/combined.tmp ./Process2/${name}.tsv
    fi 
done

# 组合 用键的方法有问题，不知道为什么
join -t $'\t' -1 1 -2 1 -o "1.1,1.2,1.3,2.2,2.3" ./Process2/h3k27ac.tsv ./Process2/atac.tsv | sort -k1,1 > blood_combined.bed
join -t $'\t' -1 1 -2 1 -o "1.1,1.2,1.3,1.4,1.5,2.2,2.3" blood_combined.bed ./Process2/ctcf.tsv | sort -k1,1 > blood_combined.tmp
mv blood_combined.tmp blood_combined.bed
echo -e "chr_start_end\th3k27ac\th3k27ac_signal\tatac\tatac_signal\tctcf\tctcf_signal" > ./Process2/blood_combined.bed
awk -F'\t' '{FS=OFS="\t"}{print $1,$2,$3,$4,$5,$6,$7}' blood_combined.bed >> ./Process2/blood_combined.bed

# atac有多少非0
#awk -F '\t' '$4 != "0"' /cluster/home/futing/Project/GBM/eqtl/Process2/blood_combined.bed | wc -l

# 看 loj wao的区别
#awk -F '\t' '$4 != "."' /cluster/home/futing/Project/GBM/eqtl/blood_left_join/atac_blood.bed | wc -l
#awk -F '\t' '$4 == "."' /cluster/home/futing/Project/GBM/eqtl/blood_left_join/atac_blood.bed | wc -l
#wc -l /cluster/home/futing/Project/GBM/eqtl/blood_wao/atac_blood_pos.bed
#awk -F '\t' '{print $4}'  /cluster/home/futing/Project/GBM/eqtl/blood_left_join/atac_blood.bed | sort | uniq | wc -l