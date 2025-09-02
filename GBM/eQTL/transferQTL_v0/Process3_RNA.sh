#!/bin/bash

eqtls_dt=./blood_left_join/blood_eqtls_uniq.bed
RNA=/cluster/home/futing/Project/GBM/HiC/12ABC_all/GBM_ABC/RNA/gene-TPM-matrix_gbm.txt
gft=/cluster/home/futing/ref_genome/hg38_gencode/humanGTF


awk 'BEGIN{OFS="\t"}NR > 1 { 
    sum = 0; 
    for (i = 2; i <= NF; i++) 
        sum += $i; 
    avg = sum / (NF - 1); 
    sub(/\..*$/, "", $1);  # 去除第一列中从 . 开始的部分
    print $1, avg 
}' /cluster/home/futing/Project/GBM/HiC/12ABC_all/GBM_ABC/RNA/gene-TPM-matrix_gbm.txt | sort -k1,1 > ./RNA/RNA_GBM.bed


cut -f1 ./RNA/RNA_GBM.bed | sort | uniq -d

awk '{
    sum[$1] += $2  # 累加相同键的第二列值
    count[$1]++    # 计数相同键的出现次数
} 
END {
    for (key in sum) {
        avg = sum[key] / count[key]  # 计算平均值
        print key, avg
    }
}' ./RNA/RNA_GBM.bed | sort -k1,1 > ./RNA/RNA_GBM.bed.tmp
mv ./RNA/RNA_GBM.bed.tmp ./RNA/RNA_GBM.bed

awk 'BEGIN{FS=OFS="\t"}
{
    
    sub(/\..*$/, "",$3)
    key = $3  # 去除第一列中 . 及其后的部分
    if (!(key in seen)) {
        seen[key] = 1
        print $0
    }
}' /cluster/home/futing/ref_genome/hg38_gencode/humanGTF | sort -k3,3 > /cluster/home/futing/ref_genome/hg38_gencode/humanGTF_de


join -1 1 -2 3 -o "2.4,2.5,2.6,2.3,2.1,1.2" ./RNA/RNA_GBM.bed ./RNA/humanGTF_de | sort -k4,4 > ./RNA/RNA_GBM_symbol.bed