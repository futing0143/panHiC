#!/bin/bash
d=$1
# reads.prepped_1.bam
cd /cluster2/home/futing/Project/HiCQTL/pipeline/gvcf_hic
outdir=/cluster2/home/futing/Project/HiCQTL/CRC_gvcf
sample=/cluster2/home/futing/Project/HiCQTL/CRCdone.txt
# 从头开始
while read -r cell; do
	if [ ! -f "$outdir/${cell}/gatk/raw_1.g.vcf.gz" ] && [ ! -f "$outdir/${cell}/bwa/reads.prepped_1.bam" ]; then
		echo "$cell" >> missing_all${d}.txt
	fi
done < "$sample"

while read -r cell; do
	if [ -f "$outdir/${cell}/bwa/reads.prepped_1.bam" ] && [ ! -f "$outdir/${cell}/gatk/raw_1.g.vcf.gz" ]; then
		echo "$cell" >> missing_gvcf${d}.txt
	fi
done < "$sample"

# 合并出了问题
while read -r cell; do
	tmp_count=`find ${outdir}/${cell}/gatk -maxdepth 1 -name "raw_*.g.vcf.gz" | wc -l`
	tmp_count2=`find ${outdir}/${cell}/gatk -maxdepth 1 -name "raw_*.g.vcf.gz.tbi" | wc -l`	
	if [ -f "$outdir/${cell}/gatk/raw_1.g.vcf.gz" ] && [ $tmp_count -eq $tmp_count2 ] && [ ! -f "$outdir/${cell}/gatk/${cell}.HC.g.vcf.gz" ]; then
		echo "$cell" >> missing_merge${d}.txt
	fi
done < "$sample"


while read -r cell; do
	if [ -f "$outdir/${cell}/gatk/${cell}.HC.g.vcf.gz" ]; then
		echo "$cell" >> done${d}.txt
	fi
done < "$sample"

while read -r cell; do
	tmp_count=`find ${outdir}/${cell}/gatk -maxdepth 1 -name "raw_*.g.vcf.gz" | wc -l`
	tmp_count2=`find ${outdir}/${cell}/gatk -maxdepth 1 -name "raw_*.g.vcf.gz.tbi" | wc -l`
	
	if [ ! $tmp_count -eq $tmp_count2 ]; then
		echo "$cell" >> missing_tbi${d}.txt
	fi
done < "$sample"