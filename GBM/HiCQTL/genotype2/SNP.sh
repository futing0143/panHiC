#!/bin/bash

# 先跑了带有gvcf的
GATK_bundle=/cluster/home/futing/ref_genome/hg38_gencode/GATK/bundle
enzyme=/cluster/home/futing/software/juicer_CPU/restriction_sites/
juicer=/cluster/home/futing/Project/GBM/HiCQTL/genotype/run_gatk_after_juicer_mod.sh

# $juicer -r ${fasta} \
# 	--gatk-bundle ${GATK_bundle} \
# 	-t 20 \
# 	${cell}.sorted.bam
#  	--from-stage "recalibrate_variants"
samples="U87,U118,U251,U343,GB176,GB180,GB182,GB183,GB238,42MGBA,A172,H4,SW1088"
scripts=/cluster/home/futing/ref_genome/hg38_gencode/GATK/wgs_gvcf_to_vcf_20180509.sh
fasta=/cluster/home/futing/ref_genome/hg38_primary_assembly/jialu/hg38.fa


$scripts $samples \
	/cluster/home/futing/Project/GBM/HiCQTL/genotype2 \
	GBM

# 不加gvcf的可以call
# for testing
# time $gatk VariantRecalibrator -R ${reference} \
# 	-V /cluster/home/futing/Project/GBM/HiCQTL/genotype/GB183/raw.vcf \
# 	-O /cluster/home/futing/Project/GBM/HiCQTL/genotype/GB183/raw2.snps.recal \
# 	--tranches-file /cluster/home/futing/Project/GBM/HiCQTL/genotype/GB183/raw2.snps.tranches \
# 	$snpRecalibrationArg --resource:mills,known=true,training=true,truth=true,prior=12.0 $GATK_bundle/Mills_and_1000G_gold_standard.indels.hg38.vcf \
# 	-mode SNP -an DP -an QD -an FS -an SOR -an ReadPosRankSum \
# 	-an MQRankSum -tranche 100.0 -tranche 99.9 -tranche 99.0 -tranche 95.0 -tranche 90.0