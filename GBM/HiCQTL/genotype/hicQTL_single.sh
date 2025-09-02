#!/bin/bash

dir=$1
en=$2
fasta=/cluster/home/futing/ref_genome/hg38_primary_assembly/bwa/hg38.fa
GATK_bundle=/cluster/home/futing/ref_genome/hg38_gencode/GATK/bundle
enzyme=/cluster/home/futing/software/juicer_CPU/restriction_sites/
juicer=/cluster/home/futing/Project/GBM/HiCQTL/run_gatk_after_juicer.sh
cell=$(echo $dir | awk -F'/' '{print $(NF-1)}')

mkdir -p /cluster/home/futing/Project/GBM/HiCQTL/${cell}
cd /cluster/home/futing/Project/GBM/HiCQTL/${cell}

echo -e "Processing $cell with enzyme $en...\n"
echo -e "Step 1: merging bam files...\n"
# ln -s ../${cell}/${cell}.bam ./${cell}.bam

ls $dir/*.fastq.gz.bam | while read -r i;do
	srr=$(basename $i .fastq.gz.bam)
	gatk AddOrReplaceReadGroups \
		-I ${i} \
		-O ${dir}/${srr}_RG.bam \
		--RGID ${srr} \
		--RGLB "Lib1" \
		--RGPL "ILLUMINA" \
		--RGPU "Unit1" \
		--RGSM $cell 
done
samtools merge -@ 8 ${cell}.bam ${dir}/*_RG.bam
samtools sort -o ${cell}.sorted.bam ${cell}.bam
samtools index -@ 20 ${cell}.sorted.bam

echo -e "Step 2: running gatk...\n"
if [ -f ${cell}.sorted.bam ];then
	$juicer -r ${fasta} \
		--gatk-bundle ${GATK_bundle} \
		-t 20 \
		${cell}.sorted.bam
else
	echo -e "Error: ${cell}.sorted.bam not found.\n"
	echo -e "Please check the input directory and try again.\n"
	exit 1
fi

# discarded running combined bam file
# ls $dir/*.fastq.gz.bam | while read -r i;do

# 	srr=$(basename $i .fastq.gz.bam)
# 	echo -e "Processing $srr in $dir... \n"
# 	$juicer -r ${fasta} \
# 	--gatk-bundle ${GATK_bundle} \
# 	-t 20 \
# 	${i} 
# 	# --gatk-bundle ${GATK_bundle} \
	
# done