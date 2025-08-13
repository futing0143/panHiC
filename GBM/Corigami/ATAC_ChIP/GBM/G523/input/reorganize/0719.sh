#!/bin/bash
#SBATCH -J G523
#SBATCH --output=./fq2bigwig_%j.log
#SBATCH --cpus-per-task=10

FASTQ_DIR="/cluster/home/futing/Project/GBM/Corigami/Training_data/GBM/G523/input/reorganize"
cd ${FASTQ_DIR}
fastq-dump --gzip --split-3 ${FASTQ_DIR}/*.sralite
sh /cluster/home/futing/pipeline/fq2bigwig_v2.sh ${FASTQ_DIR} G523_input
