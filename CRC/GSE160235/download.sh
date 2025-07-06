#!/bin/bash

cd /cluster2/home/futing/Project/panCancer/CRC/GSE160235

/cluster/home/futing/pipeline/Ascp/ascp2.sh ./HCT116.txt ./HCT116 20M

# for i in ./HCT116.txt;do
# 	echo "Processing ${i}..."
# 	gunzip -t ./${i}/*
# done