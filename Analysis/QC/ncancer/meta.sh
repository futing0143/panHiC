#!/bin/bash


meta="/cluster2/home/futing/Project/panCancer/check/aligned/aligndone1016.txt"
outputmeta=/cluster2/home/futing/Project/panCancer/Analysis/QC/ncancer/aligndone1016.txt
awk -F',' 'BEGIN{FS=OFS="\t"}{
    count[$3]++
    if (count[$3]==1) {
        uniq=$3
    } else {
        uniq=$3"_"count[$3]
    }
    print $0,uniq
}' ${meta} > tmp && mv tmp ${outputmeta}
