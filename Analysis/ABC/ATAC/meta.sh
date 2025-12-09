#!/bin/bash

cd /cluster2/home/futing/Project/panCancer/Analysis/ABC/ATAC
meta=/cluster2/home/futing/Project/panCancer/check/meta/panCan_annometa.txt

cut -f1,4 $meta | sort -u > \
	ATAC.txt
# 手动添加文件路径到最后一列
