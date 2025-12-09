#!/bin/bash

wkdir=/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/HCC

join -t $',' -1 1 -2 1 <(cut -f1,8 -d ',' ${wkdir}/GSE303623_97L-normalized_read_counts.csv) \
	<(cut -f1,8 -d ',' ${wkdir}/GSE303623_PLC-normalized_read_counts.csv) > HCC_TPM.csv

awk 'BEGIN{FS=OFS=","}
NR==1 {
    header = $0; 
    next;
}
{
    split($1, a, ".");
    id = a[1];
    ids[id] = 1;

    for (i=2; i<=NF; i++) {
        sum[id][i] += $i;
    }
}
END {
    print header;

    n = asorti(ids, sorted);   # 如果你想按 ID 排序输出

    for (k=1; k<=n; k++) {
        id = sorted[k];
        printf "%s", id;
        for (i=2; i<=NF; i++) {
            printf ",%s", sum[id][i];
        }
        printf "\n";
    }
}' HCC_TPM.csv > tmp && mv tmp HCC_TPM.csv