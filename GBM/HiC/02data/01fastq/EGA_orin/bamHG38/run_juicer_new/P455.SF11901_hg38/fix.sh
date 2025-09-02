#!/bin/bash

hg38_dir='/cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA/bamHG38/run_juicer_new/P455.SF11901_hg38'
hg19_dir='/cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA/EGAF00008040117'
# 00 header
# 提取头部信息
samtools view -H ${hg38_dir}/merged_dedup.sorted.bam > header.sam
# 删除所有 @PG 记录
grep -v "^@PG" header.sam > new_header.sam
# 重新应用头部信息
samtools reheader new_header.sam ${hg38_dir}/merged_dedup.sorted.bam > reheader.bam
# 验证结果
samtools view -H reheader.bam

# 01 define problem
java -jar /cluster/home/futing/software/picard.jar ValidateSamFile \
      I=${hg38_dir}/merged_dedup.sorted.bam \
      IGNORE_WARNINGS=true
java -jar /cluster/home/futing/software/picard.jar ValidateSamFile \
      I=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA/EGAF00008040117/reheader.bam \
      IGNORE_WARNINGS=true


#02 fix
java -jar /cluster/home/futing/software/picard.jar FixMateInformation \
      I=${hg38_dir}/reheader.bam \
      O=${hg38_dir}/fixed.bam \
      ADD_MATE_CIGAR=true > fix.log 2>&1

#03 see result
samtools view ${hg19_dir}/P455.SF1190.sorted.bam | awk '{if ($10 != "*") exit 1}'
then echo "第10列全是*"; else echo "第10列不是全是*"; fi

