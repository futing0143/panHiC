#!/bin/bash
#SBATCH -J T543
#SBATCH --output=./fq2bw%j.log
#SBATCH --cpus-per-task=15

FASTQ_DIR="/cluster/home/futing/Project/GBM/Corigami/Training_data/GBM/TS543/ChIP/H3K4me3"
OUT_NAME="T543_H3K4me3"
bamCoverage -b ${FASTQ_DIR}/bam_files/${OUT_NAME}_final.bam -o ${FASTQ_DIR}/bigwig/${OUT_NAME}_final.bw --normalizeUsing RPKM
