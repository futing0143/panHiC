#!/bin/bash
cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/GBM_split/GB176/splits

samtools view -@20 -b /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/GBM_split/GB176/splits/GB176.fastq.sam > /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/GBM_split/GB176/splits/GB176.fastq.bam
samtools sort -o G176.sorted.bam GB176.fastq.bam
samtools index G176.sorted.bam
CrossMap bam /cluster/home/futing/ref_genome/liftover/hg38ToHg19.over.chain.gz \
    ./G176.sorted.bam \
    G176_hg38

java -jar /cluster/home/futing/software/picard.jar ValidateSamFile \
      I=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/GBM_split/GB176/splits/G176.sorted.bam \
      IGNORE_WARNINGS=true > /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/GBM_split/GB176/splits/validate_orin.log

java -jar /cluster/home/futing/software/picard.jar FixMateInformation \
      I=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/GBM_split/GB176/splits/G176_hg38.sorted.bam \
      O=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/GBM_split/GB176/splits/G176_hg38.sorted.fixed.bam \
      ADD_MATE_CIGAR=true > fix.log 2>&1

samtools view /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/GBM_split/GB176/splits/G176_hg38.sorted.bam | awk '{ if ($10 == "*") { print "Found * in column 10"; exit } } END { if (NR == 0 || $10 != "*") { print "No * found in column 10" } }'

cut -d ' ' -f2 /cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA/P524.SF12681v4/aligned/merged_sort.txt | sort | uniq
