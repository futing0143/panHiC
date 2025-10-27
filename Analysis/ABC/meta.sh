#!/bin/bash
cd /cluster2/home/futing/Project/panCancer/Analysis/ABC

ln -s /cluster2/home/futing/Project/panCancer/check/panCan_meta.txt /cluster2/home/futing/Project/panCancer/Analysis/ABC
cp /cluster2/home/futing/Project/panCancer/check/panCan_meta.txt panCan_meta_ABC.txt
cp /cluster2/home/futing/Project/DepMap/RNA/missing_celllist.txt ./
# 修改 meta 文件，增加 ctrl 信息
