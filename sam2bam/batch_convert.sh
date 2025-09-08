#!/bin/bash


# cut -f2 -d ',' /cluster2/home/futing/Project/panCancer/CRC/meta/CRC_metap1.txt | while read cell;do
# 	echo "Processing cell: $cell"
# 	# 提交转换任务
# 	sh /cluster2/home/futing/Project/HiCQTL/convertSam2bam.sh /cluster2/home/futing/Project/panCancer/CRC/GSE137188/$cell
# done

# for cell in 14-151_Normal 14-1251_Normal 11-51_Normal 11-63_Normal 11-1074_Normal 12-251_Normal;do
# 	echo "Processing cell: $cell"
# 	# 提交转换任务
# 	sh /cluster2/home/futing/Project/HiCQTL/convertSam2bam.sh /cluster2/home/futing/Project/panCancer/CRC/GSE137188/$cell
# done


# cat /cluster2/home/futing/Project/HiCQTL/CRC.txt | while read cell;do
# 	echo "Processing cell: $cell"
# 	# 提交转换任务
# 	sh /cluster2/home/futing/Project/HiCQTL/convertSam2bam.sh \
# 		/cluster2/home/futing/Project/panCancer/CRC/GSE137188/$cell
# done

# IFS=$','
# while read -r gse cell enzyme;do
# 	echo "Processing $cell in $gse"
# 	sh /cluster2/home/futing/Project/HiCQTL/convertSam2bam.sh \
# 		/cluster2/home/futing/Project/panCancer/CRC/${gse}/${cell}
# done < '/cluster2/home/futing/Project/panCancer/CRC/meta/CRC_metap2.txt'


# GSE137188,13-731,MboI

cat /cluster2/home/futing/Project/panCancer/CRC/check/CRC_bam.txt | while read -r gse cell;do
	echo "Processing cell: $cell"
	# 提交转换任务
	sh /cluster2/home/futing/Project/HiCQTL/sam2bam/convertSam2bam.sh \
		/cluster2/home/futing/Project/panCancer/CRC/${gse}/$cell
done