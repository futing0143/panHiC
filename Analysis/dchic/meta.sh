#!/bin/bash


cd /cluster2/home/futing/Project/panCancer/Analysis/dchic
input=/cluster2/home/futing/Project/panCancer/check/aligned/aligndone1016.txt

# join -t $'\t' -1 3 -2 1 -o 1.1,1.2,1.3,2.2 "${input}" cell_list.tsv > tmp && mv tmp cell_list.txt
dir=/cluster2/home/futing/Project/panCancer/

awk -v dir="$dir" 'BEGIN{FS=OFS="\t"} 
{
    if ($4 == "0") {
        print dir $1 "/" $2 "/" $3 "/cool/" $3 "_100000.matrix", \
              dir $1 "/" $2 "/" $3 "/cool/" $3 "_100000_abs.bed", \
              $2"_"$3, $1
    } 
    else if ($4 == "1") {
        print dir $1 "/" $2 "/" $3 "/cool/" $3 "_100000.matrix", \
              dir $1 "/" $2 "/" $3 "/cool/" $3 "_100000_abs.bed", \
              $2"_"$3, $1 "_ctrl"
    }
}' cell_list.txt > input.txt

ls /cluster2/home/futing/Project/panCancer/Analysis/dchic/pca/*_cor.txt \
	| xargs -n1 basename | sed 's/_cor\.txt$//' | sort -u > cancer_listdone.txt

# input 再去除 PCundone

# 娜姐的数据
cd /cluster2/home/futing/Project/panCancer/Analysis/dchic/meta
grep -F -f <(cut -f2 ATAC.txt) data_metainfo.csv | cut -f2-11 -d ',' | sort -t',' -k8,8 -k7,7 > ATAC_meta.txt
awk -F',' '{
    cell=$8
    type=$7
    if(type=="ChIP"){has_chip[cell]=1}
    if(type=="Input"){has_input[cell]=1}
    lines[cell]=lines[cell] $0 ORS
}
END{
    for(c in lines){
        if(has_chip[c] && has_input[c]) printf "%s", lines[c]
    }
}' /cluster2/home/futing/Project/panCancer/Analysis/dchic/ATAC_meta.txt \
> tmp && mv tmp /cluster2/home/futing/Project/panCancer/Analysis/dchic/ATAC_meta.txt

# 手动删除 input 和 ChIP的关系
