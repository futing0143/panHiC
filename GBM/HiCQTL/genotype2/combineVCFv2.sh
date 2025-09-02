#!/bin/bash

outdir=/cluster/home/futing/Project/GBM/HiCQTL/genotype2
outname=GBM
samples="U87,U118,U251,U343,GB176,GB180,GB182,GB183,GB238,42MGBA,A172,H4,SW1088"
samples=$(echo $samples | tr "," "\n")
gatk=/cluster/home/futing/software/gatk-4.6.2.0/gatk
#reference
reference=/cluster/home/futing/ref_genome/hg38_primary_assembly/bwa/hg38.fa
GATK_bundle=/cluster/home/futing/ref_genome/hg38_gencode/GATK/bundle

# 本想合并gvcf，但是HiC数据gvcf有问题，整个文件夹作废

# 原始数据合并
mkdir -p $outdir/population

sample_gvcfs=()
for sample in $samples; do
	sample_gvcfs+=("-V" "$outdir/${sample}/raw.vcf")
done

time $gatk CombineGVCFs \
	-R ${reference} \
	"${sample_gvcfs[@]}" \
	-O $outdir/population/${outname}.HC.g.vcf.gz && echo "** ${outname}.HC.g.vcf.gz done ** " && \
time $gatk GenotypeGVCFs \
	-R ${reference} \
	-V $outdir/population/${outname}.HC.g.vcf.gz \
	-O $outdir/population/${outname}.HC.vcf.gz && echo "** ${outname}.HC.vcf.gz done ** "


# genotype2不行，genotype可以
time $gatk GenotypeGVCFs \
	-R ${reference} \
	-V /cluster/home/futing/Project/GBM/HiCQTL/genotype2/U343/raw.vcf \
	-O /cluster/home/futing/Project/GBM/HiCQTL/genotype2/U343/raw.g.vcf




