#!/bin/bash

# 处理 pre_meta.txt
cd /cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA
metafile=/cluster2/home/futing/Project/panCancer/check/meta/panCan_meta.txt

ln -s ${metafile} /cluster2/home/futing/Project/panCancer/Analysis/ABC
# 把新的panCan_meta.txt 数据添加到 pre_meta.txt 里
grep -v -w -F -f <(cut -f1-3 /cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/CCLE/pre_meta.txt) \
	../panCan_meta.txt > panCan_meta_cl1127.txt
awk 'BEGIN{FS=OFS="\t"}{print $1,$2,$3,$3}' panCan_meta_cl.txt | sort -u \
	>> /cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/CCLE/pre_meta.txt
	
# 手动处理cellname不一致的问题，去除里面的病人样本，得到 ATAC.txt和 pre_meta.txt

# --- 01 处理 RNA 数据
cp /cluster2/home/futing/Project/DepMap/RNA/missing_celllist.txt ./

# 合并新添加的
grep -w -v -F -f <(tail -n +2 ./RNA/cell_done.txt | cut -f1-3) ./panCan_meta_cl.txt \
	> ./RNA/missing_celllist${d}.txt

# 
cp /cluster2/home/futing/Project/panCancer/check/panCan_meta.txt ./ATAC/panCan_meta_ATAC.txt