#!/bin/bash

cd /cluster/home/futing/Project/GBM/WGS/GSE202644
name=$1


# samtools view -H ./${name}/bwa/${name}.sorted.bam > ./${name}/bwa/header.sam
# grep -v '^@RG' ./${name}/bwa/header.sam > ./${name}/bwa/clean_header.sam
# samtools reheader ./${name}/bwa/header.sam ./${name}/bwa/${name}.sorted.bam > ./${name}/bwa/${name}.sorted.noRG.bam
# gatk AddOrReplaceReadGroups \
# 	-I ./${name}/bwa/${name}.sorted.noRG.bam \
# 	-O ./${name}/bwa/${name}.sorted.fixRG.bam \
# 	-RGID "01" \
# 	-RGLB "lib1" \
# 	-RGPL "ILLUMINA" \
# 	-RGPU "unit1" \
# 	-RGSM ${name} \
# 	-VALIDATION_STRINGENCY LENIENT \
# 	-CREATE_INDEX false

# mv ./${name}/bwa/${name}.sorted.noRG.bam ./${name}/bwa/${name}.sorted.bam

/cluster/home/futing/ref_genome/hg38_gencode/GATK/wgs_fastq_to_gvcf_20180509_p2.sh \
	${name}.R1.fastq.gz \
	${name}.R2.fastq.gz \
	"01" \
	"lib1" \
	${name} \
	/cluster/home/futing/Project/GBM/WGS/GSE202644

