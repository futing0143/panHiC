#!/bin/bash


cat /cluster2/home/futing/Project/panCancer/CRC/check/CRC_bam0711.txt | while read -r gse cell;do
	echo "Processing cell: $cell"
	# 提交转换任务
	sh /cluster2/home/futing/Project/HiCQTL/sam2bam/convertSam2bam.sh \
		/cluster2/home/futing/Project/panCancer/CRC/${gse}/$cell
done