#!/bin/bash

loopdir=/cluster/home/futing/Project/GBM/HiC/10loop/consensus/merged/flank0k
chip_dir=/cluster/home/futing/Project/GBM/HiC/hubgene/new/H3K27ac/merge
HAR=/cluster/home/futing/Project/GBM/HiC/HAR/HARs_hg38.bed
HAR=/cluster/home/futing/Project/GBM/HiC/HAR/haqer.hg38.bed
name=HARs
cd /cluster/home/futing/Project/GBM/HiC/HAR

# ------- HARs chip peak coverage
# awk '{FS=OFS="\t"}{print $1,1,$2}' ~/ref_genome/hg38.genome > ~/ref_genome/hg38.genome.bed
# 输出：
# HAR区域在不同染色体覆盖率 ./${name}_coverage/${name}_coveragev2.txt
# 每个sample与HARs的交集与覆盖率 ./${name}_coverage/${i}_${name}_coverage.txt ./overlap/${i}_${name}.bed
# 合并的每个sample与HARs的覆盖长度与覆盖数量 ./${name}_coverage/${name}_H3K27ac_coverage.txt

# 01 ChIP signal coverage
# 直接合并计算好的
outfile=./ChIP_coverage/H3K27ac_coverage.txt

awk '{OFS="\t"}{print $1}' ${chip_dir}/iPSC_chip_coverage.txt \
	> ./ChIP_coverage/H3K27ac_coverage.txt
for i in GBM NHA NPC iPSC;do
	cut -f7 ${chip_dir}/${i}_chip_coverage.txt | paste ./ChIP_coverage/H3K27ac_coverage.txt - >> ./ChIP_coverage/H3K27ac_coverage.tmp
	mv ./ChIP_coverage/H3K27ac_coverage.tmp ./ChIP_coverage/H3K27ac_coverage.txt
done

echo -e "chr\tGBM\tNHA\tNPC\tiPSC" > ./ChIP_coverage/H3K27ac_coverage.tmp
awk '{OFS="\t"}{print $0}' ./ChIP_coverage/H3K27ac_coverage.txt >> ./ChIP_coverage/H3K27ac_coverage.tmp
mv ./ChIP_coverage/H3K27ac_coverage.tmp ./ChIP_coverage/H3K27ac_coverage.txt


# 02 计算 HAR 与 ChIP signal 的覆盖
awk '{print $1"\t"($3-$2)}' ${name}_merged.bed | 
	datamash -g 1 sum 2 count 2 > ./${name}_coverage/${name}_coverage.txt
awk '{OFS="\t"}{print $1,$2,$3}' ./${name}_coverage/${name}_coverage.txt \
	> ./${name}_coverage/H3K27ac/${name}_H3K27ac_coverage.txt

# 

for i in GBM NPC; do #NHA iPSC 

	# 计算 loop anchor 与 HAR 覆盖长度
	bedtools intersect -a ${name}_merged.bed \
		-b ${chip_dir}/${i}.merge_BS_detail.bed \
		-wo > ./overlap/H3K27ac/${i}_${name}.bed

	# 提取每个染色体 HARs 和 loop anchor 的覆盖长度
	awk '{print $1"\t"$NF}' ./overlap/H3K27ac/${i}_${name}.bed | 
		datamash -g 1 sum 2 count 2 > ./${name}_coverage/H3K27ac/${i}_${name}_coverage.txt

	# 提取每个染色体上HARs覆盖长度，及 HARs 和 loop anchor 的覆盖长度，并且计算 HAR 与 loop anchor 的覆盖率
	cut -f2-3 ./${name}_coverage/H3K27ac/${i}_${name}_coverage.txt \
		| paste ./${name}_coverage/H3K27ac/${name}_H3K27ac_coverage.txt - \
		>> ./${name}_coverage/H3K27ac/${name}_H3K27ac_coverage.tmp
	mv ./${name}_coverage/H3K27ac/${name}_H3K27ac_coverage.tmp \
		./${name}_coverage/H3K27ac/${name}_H3K27ac_coverage.txt

done

echo -e "chr\tlHARs\tnHARs\tlGBM\tnGBM\tlNHA\tnNHA\tliPSC\tniPSC\tlNPC\tnNPC" > ./${name}_coverage/H3K27ac/${name}.tmp
echo -e "chr\tlHARs\tnHARs\tlGBM\tnGBM\tlNPC\tnNPC" > ./${name}_coverage/H3K27ac/${name}.tmp
awk '{OFS="\t"}{print $0}' ./${name}_coverage/H3K27ac/${name}_H3K27ac_coverage.txt >> ./${name}_coverage/H3K27ac/${name}.tmp
mv ./${name}_coverage/H3K27ac/${name}.tmp ./${name}_coverage/H3K27ac/${name}_H3K27ac_coverage.txt


# 将 loop 分别与 gene HARs Enhancer联系起来
# 这样做有个问题，如果选用Enhancer和loop anchor取交集，则可能出现Enhancer有交集，但是HARs与loop anchor没有交集
# 但是有一点偏差影响大吗？

EHAERs=/cluster/home/futing/Project/GBM/HiC/HAR/overlap/H3K27ac/${i}_HARs.bed

loopdir=/cluster/home/futing/Project/GBM/HiC/10loop/consensus/cytoscape


cut -f1-3 $ENAERs | pairToBed -a $loopdir/${i}/${i}_loop.bed -b >  ./method2/${i}.bedpe.tmp

pairToBed -a ./method2/${i}.bedpe.tmp -b 