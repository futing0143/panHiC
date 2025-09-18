#!/bin/bash


debug=/cluster2/home/futing/Project/HiCQTL/CRC_gvcf/debug
cd $debug
cell_hap=/cluster2/home/futing/Project/HiCQTL/cell_hap0908.txt
>$cell_hap
# Search for files containing this specific error
grep -rl "cannot remove.*recal_data_1.table.*No such file" ${debug:-.} \
	> cell_hap0908.txt

while IFS= read -r line; do
	filename="${line##*/}"          # 获取文件名
	basename="${filename%.log}"     # 移除.log后缀
	# 移除最后一部分（日期时间）
	cell="${basename%-*}"
	echo "$cell" >> ${cell_hap}
done < "cell_hap0908.txt"

logfile=/cluster2/home/futing/Project/HiCQTL/debug/GVCF-12577.log
cut -f2 -d ' ' $logfile | cut -f1 -d '.' | sort | uniq > all_gvcf_id.txt
logfile=/cluster2/home/futing/Project/HiCQTL/debug/GVCF-12578.log
cut -f2 -d ' ' $logfile | cut -f1 -d '.' | sort | uniq >> all_gvcf_id.txt

grep -rl ":( Failed at GATK GatherVcfs. See err stream for more info. Exiting!" ${debug:-.} \
	> gathervcf_error.txt

comGVCF=/cluster2/home/futing/Project/HiCQTL/cell_comGVCF0908.txt
>$comGVCF
while IFS= read -r line; do
	filename="${line##*/}"          # 获取文件名
	basename="${filename%.log}"     # 移除.log后缀
	# 移除最后一部分（日期时间）
	cell="${basename%-*}"
	echo "$cell" >> ${comGVCF}
done < "gathervcf_error.txt"