#!/bin/bash

dir=$1
en=$2

fasta=/cluster/home/futing/software/juicer_CPU/references/hg38.fa
GATK_bundle=/cluster/home/futing/ref_genome/hg38_gencode/GATK/bundle
enzyme=/cluster/home/futing/software/juicer_CPU/restriction_sites/
juicer=/cluster2/home/futing/Project/HiCQTL/run_gatk_after_juicer.sh
cell=$(echo $dir | awk -F'/' '{print $(NF-1)}')

mkdir -p /cluster2/home/futing/Project/HiCQTL/CRC/${cell}
cd /cluster2/home/futing/Project/HiCQTL/CRC/${cell}

# 01 合并所有的
if [ ! -e "${cell}.sorted.bam" ] || [ ! -s "${cell}.sorted.bam" ];then
	echo -e "Processing $cell ...\n" #with enzyme $en
	echo -e "Step 1: merging bam files...\n"
	ls $dir/*.fastq.gz.bam | while read -r i;do
		srr=$(basename $i .fastq.gz.bam)
		gatk AddOrReplaceReadGroups \
			-I ${i} \
			-O ${dir}/${srr}_RG.bam \
			--RGID ${srr} \
			--RGLB "Lib1" \
			--RGPL "ILM" \
			--RGPU "Unit1" \
			--RGSM $cell 
	done
	samtools merge -@ 20 ${cell}.bam ${dir}/*_RG.bam
	samtools sort -@ 20 ${cell}.bam -o ${cell}.sorted.bam
	samtools index ${cell}.sorted.bam
	rm ${dir}/*_RG.bam ${cell}.bam
else
	echo "${cell}.bam exits..."
fi

# 02 运行gatk
echo -e "Step 2: running gatk...\n"
$juicer -r ${fasta} \
	--gatk-bundle ${GATK_bundle} \
	--from-stage 'recalibrate_variants' \
	-t 20 \
	${cell}.sorted.bam
	
	# 