#!/bin/bash

reference=/cluster/home/futing/ref_genome/hg38_primary_assembly/bwa/hg38.fa
gatk  --java-options "-Xmx4G -XX:+UseParallelGC -XX:ParallelGCThreads=1" HaplotypeCaller \
	-R $reference -I reads.prepped_1.bam -O raw_1.vcf 
gatk  --java-options -Xmx4G -XX:+UseParallelGC -XX:ParallelGCThreads=1 HaplotypeCaller \
	-R $reference -I 42MGBA_sorted.bam -O raw.vcf 

gatk --java-options "-Xmx4G -XX:+UseParallelGC -XX:ParallelGCThreads=40" VariantRecalibrator \
	-V raw.vcf -O out.recal -mode SNP --tranches-file out.tranches \
	-tranche 100.0 -tranche 99.9 -tranche 99.0 -tranche 90.0 -an QD -an FS \
	-an MQRankSum -an ReadPosRankSum -an SOR -an MQ --max-gaussians 6 ${snpRecalibrationArg}

gatk --java-options "-Xmx4G -XX:+UseParallelGC -XX:ParallelGCThreads=20" ApplyVQSR \
	-V raw_sorted.vcf -O recalibrated_snps_raw_indels.vcf --recal-file out_sorted.recal \
	--tranches-file out.tranches \
	-truth-sensitivity-filter-level 99.5 --create-output-variant-index true -mode SNP
