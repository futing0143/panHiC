#!/bin/bash

for cell in G523 G583 G567;do

	nohup /cluster2/home/futing/Project/panCancer/GBM/GSE162976/calres.sh \
	/cluster2/home/futing/Project/GBM/HiC/02data/02hic/GBM_mid/${cell}/${cell}.5000.bedpe.short.sorted \
	/cluster2/home/futing/Project/panCancer/GBM/GSE162976/${cell}/aligned/50bp.txt \
	> /cluster2/home/futing/Project/panCancer/GBM/GSE162976/${cell}_res.log 2>&1 &
done