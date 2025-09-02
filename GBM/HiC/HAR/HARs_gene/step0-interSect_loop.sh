#!/bin/bash

cd /cluster/home/futing/Project/GBM/HiC/HAR/HARs_gene/EPs

loopdir=/cluster/home/futing/Project/GBM/HiC/10loop/consensus/cytoscape
HARs=/cluster/home/futing/Project/GBM/HiC/HAR/HARs_merged.bed
EHARs=/cluster/home/futing/Project/GBM/HiC/HAR/HARs_gene/diffEn/GBM_HAR.bed

# 筛选有
bedtools intersect -a $HARs \
	-b /cluster/home/futing/Project/GBM/HiC/HAR/HARs_gene/diffEn/GBM_vs_NPC_deseq2_all.bed3 \
	-wa -wb | cut -f1-3 > $EHARs


for i in NPC NHA iPSC GBM;do #GBM 
	# 实际上我们只关心 E-P 那些loop
	
	awk 'BEGIN { FS=OFS="\t" }
	NR > 1 {
		if ($5 == 1) {   # || $6 == 1
			# 使用正则表达式分别以冒号、连字符和下划线拆分第一列
			split($1, arr, /[:\-_]/)
			# 构造新输出行：先输出拆分得到的6个字段，再输出原始整行
			print arr[1], arr[2], arr[3], arr[4], arr[5], arr[6], $2, $3, $4, $5, $6, $7, $8, $9, $10
		}
	}' $loopdir/${i}/${i}_loop.bed | sort | uniq > ./EPs/GBMup/${i}.tmp
	pairToBed -a ./EPs/GBMup/${i}.tmp -b $EHARs > ./EPs/GBMup/${i}_HARs.bedpe
	echo -e "chr1\tstart1\tend1\tchr2\tstart2\tend2\tbin1\tbin2\tE-E\tE-P\tP-P\tother\tbin1_info\tbin2_info\tgene\tchr_H\tstart_H\tend_H" \
		> ./EPs/GBMup/${i}_HARs.tmp
	awk '{OFS="\t"}{print $0}' ./EPs/GBMup/${i}_HARs.bedpe >> ./EPs/GBMup/${i}_HARs.tmp 
	mv ./EPs/GBMup/${i}_HARs.tmp ./EPs/GBMup/${i}_HARs.bedpe
	rm ./EPs/GBMup/${i}.tmp
done


