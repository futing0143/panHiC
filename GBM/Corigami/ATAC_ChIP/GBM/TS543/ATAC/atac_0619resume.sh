#!/bin/bash
#SBATCH -J atac
#SBATCH --output=./atac_pipeline_%j.log
#SBATCH --cpus-per-task=20

REF_GENOME="/cluster/share/ref_genome/GRCh38.p13/index/bowtie2/GRCh38.p13.fa"
FASTQ_DIR="/cluster/home/futing/Project/GBM/Corigami/Training_data/TS543/ATAC/old_0614"
OUT_NAME="T543_new"

mkdir -p ${FASTQ_DIR}/{fastqc,filter,fastqc_filt,align,bigwig}
cd ${FASTQ_DIR}

# Step 2: qc
fastqc ${FASTQ_DIR}/*.fastq.gz -o ${FASTQ_DIR}/fastqc
#trim_galore --phred33 -q 20 --length 20 --stringency 3 -e 0.1 --paired -o ${FASTQ_DIR}/filter merged1.fastq.gz merged2.fastq.gz
fastqc ${FASTQ_DIR}/qc/*.gz -o ${FASTQ_DIR}/fastqc_filt
multiqc -o ${FASTQ_DIR}/fastqc ${FASTQ_DIR}/fastqc/*zip
multiqc -o ${FASTQ_DIR}/fastqc_filt ${FASTQ_DIR}/fastqc_filt/*zip

# Step 3: Read Alignment
bowtie2 -x ${REF_GENOME} -U ${FASTQ_DIR}/qc/*.gz | samtools view -bS - > ${FASTQ_DIR}/align/aligned.bam
samtools sort ${FASTQ_DIR}/align/aligned.bam -o ${FASTQ_DIR}/align/sorted.bam
samtools index ${FASTQ_DIR}/align/sorted.bam

# Step 4: Preprocessing
picard MarkDuplicates I=${FASTQ_DIR}/align/sorted.bam O=${FASTQ_DIR}/align/dedup.bam M=${FASTQ_DIR}/align/metrics.txt REMOVE_DUPLICATES=true
samtools index ${FASTQ_DIR}/align/dedup.bam
samtools view -F 0x200 -q 30 ${FASTQ_DIR}/align/dedup.bam -b > ${FASTQ_DIR}/align/filtered.bam
samtools view -h ${FASTQ_DIR}/align/filtered.bam | grep "Mt" -v | grep "Pt" -v | samtools view -b -o ${FASTQ_DIR}/align/${OUT_NAME}_final.bam
samtools index ${FASTQ_DIR}/align/${OUT_NAME}_final.bam

# Step 5: BAM2BigWIg 
bamCoverage -b ${FASTQ_DIR}/align/${OUT_NAME}_final.bam -o ${FASTQ_DIR}/bigwig/${OUT_NAME}_final.bw
echo "BAM2BigWig completed!"

echo "ATAC-seq analysis completed!"