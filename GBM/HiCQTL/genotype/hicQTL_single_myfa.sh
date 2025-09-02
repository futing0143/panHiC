#!/bin/bash

dir=$1
en=$2
fasta=/cluster/home/futing/ref_genome/hg38_primary_assembly/bwa/hg38.fa
# fasta=/cluster/home/futing/ref_genome/hg38_primary_assembly/jialu/hg38.fa
GATK_bundle=/cluster/home/futing/ref_genome/hg38_gencode/GATK/bundle
enzyme=/cluster/home/futing/software/juicer_CPU/restriction_sites/
juicer=/cluster/home/futing/Project/GBM/HiCQTL/genotype/run_gatk_after_juicer_mod.sh
cell=$(echo $dir | awk -F'/' '{print $(NF-1)}')

mkdir -p /cluster/home/futing/Project/GBM/HiCQTL/genotype2/${cell}
cd /cluster/home/futing/Project/GBM/HiCQTL/genotype2/${cell}

echo -e "Processing $cell with enzyme $en...\n"
echo -e "Step 1: merging bam files...\n"
ln -s /cluster/home/futing/Project/GBM/HiCQTL/genotype/${cell}/${cell}.sorted.bam ./${cell}.sorted.bam

# ls $dir/*.fastq.gz.bam | while read -r i;do
# 	srr=$(basename $i .fastq.gz.bam)
# 	gatk AddOrReplaceReadGroups \
# 		-I ${i} \
# 		-O ${dir}/${srr}_RG.bam \
# 		--RGID ${srr} \
# 		--RGLB "Lib1" \
# 		--RGPL "ILLUMINA" \
# 		--RGPU "Unit1" \
# 		--RGSM $cell 
# done
# samtools merge -@ 8 ${cell}.bam ${dir}/*_RG.bam
# samtools index ${cell}.bam

echo -e "Step 2: running gatk...\n"
$juicer -r ${fasta} \
	--gatk-bundle ${GATK_bundle} \
	-t 20 \
	${cell}.sorted.bam
 	# --from-stage "recalibrate_variants" \

