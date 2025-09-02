#!/bin/bash

loopdir=/cluster/home/futing/Project/GBM/HiC/10loop/consensus/merged/flank0k
HAR=/cluster/home/futing/Project/GBM/HiC/HAR/HARs_hg38.bed
HAR=/cluster/home/futing/Project/GBM/HiC/HAR/haqer.hg38.bed
name=HARs
cd /cluster/home/futing/Project/GBM/HiC/HAR

# 01 overlap with loop anchor
# useless 
# tail -n +2 /cluster/home/futing/Project/GBM/HiC/HAR/GSE180714_HARs.bed \
# 	> /cluster/home/futing/Project/GBM/HiC/HAR/HARs.bed

bigBedToBed HARs.bb HARs_hg38.bed

for i in GBM NPC iPSC NHA;do
	pairToBed -a $loopdir/${i}_flank0k.bedpe -b $HAR > \
		./${i}_HAR.bedpe
done

# ------- HARs loop anchor coverage
# awk '{FS=OFS="\t"}{print $1,1,$2}' ~/ref_genome/hg38.genome > ~/ref_genome/hg38.genome.bed
# 输出：
# HAR区域在不同染色体覆盖率 ./${name}_coverage/${name}_coveragev2.txt
# 每个sample与HARs的交集与覆盖率 ./${name}_coverage/${i}_${name}_coverage.txt ./overlap/${i}_${name}.bed
# 合并的每个sample与HARs的覆盖长度与覆盖数量 ./${name}_coverage/${name}_sample_coverage.txt

# 01 先计算一下 HAR 区域在不同染色体的覆盖率

cut -f1-3 $HAR | sort -k1,1d -k2,2n | bedtools merge > ${name}_merged.bed
HAR_merge=./${name}_merged.bed

bedtools coverage -a ~/ref_genome/hg38.genome.bed \
	-b $HAR_merge > ./${name}_coverage/${name}_coveragev2.txt

# 02 计算 HAR 与 loop anchor 的覆盖
awk '{print $1"\t"($3-$2)}' HAQERs_merged.bed | 
	datamash -g 1 sum 2 count 2 > ./${name}_coverage/${name}_coverage.txt
awk '{OFS="\t"}{print $1,$2,$3}' ./${name}_coverage/${name}_coverage.txt \
	> ./${name}_coverage/${name}_sample_coverage.txt
	
for i in GBM NPC; do #NHA iPSC 
	awk '{print $1"\t"$2"\t"$3; print $4"\t"$5"\t"$6}' $loopdir/${i}_flank0k.bedpe | 
	sort -k1,1 -k2,2n | 
	bedtools merge > ./overlap/${i}.bed

	# 计算 loop anchor 与 HAR 覆盖长度
	bedtools intersect -a $HAR_merge \
		-b ./overlap/${i}.bed \
		-wo > ./overlap/${i}_${name}.bed

	# 提取每个染色体 HARs 和 loop anchor 的覆盖长度
	awk '{print $1"\t"$NF}' ./overlap/${i}_${name}.bed | 
		datamash -g 1 sum 2 count 2 > ./${name}_coverage/${i}_${name}_coverage.txt

	# 提取每个染色体上HARs覆盖长度，及 HARs 和 loop anchor 的覆盖长度，并且计算 HAR 与 loop anchor 的覆盖率
	cut -f2-3 ./${name}_coverage/${i}_${name}_coverage.txt \
		| paste ./${name}_coverage/${name}_sample_coverage.txt - \
		>> ./${name}_coverage/${name}_sample_coverage.tmp
	mv ./${name}_coverage/${name}_sample_coverage.tmp \
		./${name}_coverage/${name}_sample_coverage.txt

done

echo -e "chr\tlHARs\tnHARs\tlGBM\tnGBM\tlNHA\tnNHA\tliPSC\tniPSC\tlNPC\tnNPC" > ./${name}_coverage/${name}.tmp
awk '{OFS="\t"}{print $0}' ./${name}_coverage/${name}_sample_coverage.txt >> ./${name}_coverage/${name}.tmp
mv ./${name}_coverage/${name}.tmp ./${name}_coverage/${name}_sample_coverage.txt


