#!/bin/bash
d=1112
cldata=/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/CCLE/pre_meta.txt	# clean name 的 meta
donemeta="/cluster2/home/futing/Project/panCancer/check/post/insul/insul50k_done${d}.txt" # check输出insul名单
ctrlmeta=/cluster2/home/futing/Project/panCancer/Analysis/dchic/meta/cell_list/cell_list_all.txt # 添加了 isctrl 的meta
outputmeta="/cluster2/home/futing/Project/panCancer/Analysis/conserve/insul50k_${d}.txt" # 添加了clean name的输出

cd /cluster2/home/futing/Project/panCancer/Analysis/conserve


grep -F -f <(cut -f1-3 ${donemeta}) ${cldata} > $outputmeta

awk -F',' 'BEGIN{FS=OFS="\t"}{
    count[$4]++
    if (count[$4]==1) {
        uniq=$4
    } else {
        uniq=$4"_"count[$4]
    }
    print $0,uniq
}' ${outputmeta} > tmp 

# 按照前三列合并，加入 isctrl 信息
awk 'NR==FNR{key=$1"\t"$2"\t"$3; data[key]=$0; next}
{
  key=$1"\t"$2"\t"$3
  if(key in data)
     print data[key]"\t"$4
}' tmp $ctrlmeta  >  $outputmeta
rm tmp

# # 检查 insul 文件行数
# while IFS=$'\t' read -r cancer gse cell clcell ncell; do
#     file="/cluster2/home/futing/Project/panCancer/${cancer}/$gse/$cell/anno/insul/${cell}_50000.tsv"
# 	linecount=$(wc -l $file | awk '{print $1}')
# 	echo -e "${cancer}\t${gse}\t${cell}\t${clcell}\t${ncell}\t${linecount}" >> insul50k_linecount${d}.txt
# done < $outputmeta


# fix bin的ID问题

cut -f1-3 /cluster2/home/futing/Project/panCancer/OS/GSE90003/U2OS/anno/insul/U2OS_50000.tsv > tmp
paste -d '\t' tmp <(cut -f4- /cluster2/home/futing/Project/panCancer/Analysis/conserve/Cancer_412_BS8.tsv) > /cluster2/home/futing/Project/panCancer/Analysis/conserve/Cancer_412_BS8_fix.tsv &&
	mv /cluster2/home/futing/Project/panCancer/Analysis/conserve/Cancer_412_BS8_fix.tsv \
	/cluster2/home/futing/Project/panCancer/Analysis/conserve/Cancer_412_BS8.tsv
rm tmp