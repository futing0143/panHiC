#!/bin/bash
d=1211
panCanmeta=/cluster2/home/futing/Project/panCancer/check/meta/panCan_annometa.txt
donemeta="/cluster2/home/futing/Project/panCancer/check/post/insul/insul50k_done${d}.txt" # check输出insul名单


cd /cluster2/home/futing/Project/panCancer/Analysis/conserve

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