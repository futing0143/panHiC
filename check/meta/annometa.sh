#!/bin/bash

cd /cluster2/home/futing/Project/panCancer/check/meta
cldata=/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/CCLE/pre_meta.txt	# clean name 的 meta
ctrlmeta=/cluster2/home/futing/Project/panCancer/Analysis/dchic/meta/cell_list/cell_list_all.txt # 添加了 isctrl 的meta
panCanmeta=/cluster2/home/futing/Project/panCancer/check/meta/panCan_annometa.txt # 包含 cancer, gse, cell, ncell 信息

# 先添加unique cell_number 信息
awk -F',' 'BEGIN{FS=OFS="\t"}{
    count[$4]++
    if (count[$4]==1) {
        uniq=$4
    } else {
        uniq=$4"_"count[$4]
    }
    print $0,uniq
}' <(tail -n +2 $cldata) > tmp 


# 按照前三列合并，加入 isctrl 信息
awk 'NR==FNR{key=$1"\t"$2"\t"$3; data[key]=$0; next}
{
  key=$1"\t"$2"\t"$3
  if(key in data)
     print data[key]"\t"$4
}' tmp $ctrlmeta  >  $panCanmeta
rm tmp