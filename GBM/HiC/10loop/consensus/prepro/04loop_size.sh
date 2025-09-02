#!/bin/bash

cd /cluster/home/futing/Project/GBM/HiC/10loop/consensus/mid
resultfile=/cluster/home/futing/Project/GBM/HiC/10loop/consensus/result/QC_6/sloop_sample.txt

# 直接计算大于2个重复的loop的大小   
echo -e "chr\tsize\tnum\tsample" > $resultfile
cat /cluster/home/futing/Project/GBM/HiC/10loop/consensus/namelist.txt | while read name;do
    echo "Processing $name"
    file=/cluster/home/futing/Project/GBM/HiC/10loop/consensus/mid/${name}/${name}_over2.bed
    awk -v id=$name 'BEGIN{FS=OFS="\t"}NR>1{print $1,$3-$2,$NF,id}' $file >> $resultfile
done
