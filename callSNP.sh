#!/bin/bash

bam=$1  ## 样本ID
outdir=$(dirname ${bam})
sample=$(basename ${outdir})

# 一些软件和工具的路径, 根据实际
trimmomatic=~/miniforge-pypy3/envs/HiC/bin/trimmomatic
bwa=~/miniforge-pypy3/envs/HiC/bin/bwa
samtools=~/miniforge-pypy3/envs/HiC/bin/samtools
gatk=/cluster/home/futing/software/gatk-4.6.2.0/gatk

#reference
reference=/cluster/home/futing/ref_genome/hg38_gencode/bwa/hg38.fa
GATK_bundle=/cluster/home/futing/ref_genome/hg38_gencode/GATK/bundle

if [ ! -d $outdir/bwa ]
then mkdir -p $outdir/bwa
fi

if [ ! -d $outdir/gatk ]
then mkdir -p $outdir/gatk
fi

$gatk MarkDuplicates \
  -I ${bam} \
  -M $outdir/bwa/${sample}.markdup_metrics.txt \
  -O $outdir/bwa/${sample}.sorted.markdup.bam && echo "** ${sample}.sorted.bam MarkDuplicates done **"


time $gatk BaseRecalibrator \
    -R ${reference} \
    -I $outdir/bwa/${sample}.sorted.markdup.bam \
    --known-sites $GATK_bundle/1000G_phase1.snps.high_confidence.hg38.vcf \
    --known-sites $GATK_bundle/Mills_and_1000G_gold_standard.indels.hg38.vcf \
    --known-sites $GATK_bundle/dbsnp138.hg38.vcf \
    -O $outdir/bwa/${sample}.sorted.markdup.recal_data.table && echo "** ${sample}.sorted.markdup.recal_data.table done **" 

time $gatk ApplyBQSR \
    --bqsr-recal-file $outdir/bwa/${sample}.sorted.markdup.recal_data.table \
	-R ${reference} \
	-I $outdir/bwa/${sample}.sorted.markdup.bam \
	-O $outdir/bwa/${sample}.sorted.markdup.BQSR.bam && echo "** ApplyBQSR done **"

## 输出样本的全gVCF，面对较大的输入文件时，速度较慢
time $gatk HaplotypeCaller \
	--emit-ref-confidence GVCF \
	--native-pair-hmm-threads 8 \
	-R ${reference} \
	-I $outdir/bwa/${sample}.sorted.markdup.BQSR.bam \
	-O $outdir/gatk/${sample}.HC.g.vcf.gz && echo "** GVCF ${sample}.HC.g.vcf.gz done **"