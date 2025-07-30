#!/bin/bash
source activate HiC
FileName=DLD-12
bname=/cluster2/home/futing/Project/panCancer/CRC/GSE178593/DLD-12
# 创建修复后的文件
# gunzip -c ${bname}/aligned2/${FileName}.nodups.sorted.pairs.gz | \
# awk 'BEGIN{OFS="\t"} /^#/{print; next} {if($2>$4||($2==$4&&$3>$5)){t=$2;$2=$4;$4=t; t=$3;$3=$5;$5=t; t=$6;$6=$7;$7=t; if(NF>=10){t=$9;$9=$10;$10=t}} print}' | \
# pairtools sort --nproc 15 --tmpdir ${bname}/tmp | \
# bgzip > ${bname}/aligned2/${FileName}.nodups.sorted.fixed.pairs.gz && \
# pairix ${bname}/aligned2/${FileName}.nodups.sorted.fixed.pairs.gz

threads=10
binsize=5000
chromsize=/cluster/home/futing/software/juicer_CPU/restriction_sites/hg38.genome
cooler cload pairix --nproc ${threads} \
	${chromsize}:${binsize} \
	${bname}/aligned2/${FileName}.nodups.sorted.fixed.pairs.gz \
	${bname}/aligned2/${FileName}.${binsize}.cool
