#!/bin/bash
#SBATCH -J 523_atac
#SBATCH --output=./fq2bigwig_%j.log
#SBATCH --cpus-per-task=10

source conda activate atac_seq
FASTQ_DIR="/cluster/home/futing/Project/GBM/Corigami/Training_data/GBM/TS543/ATAC/SRR12055979/"
cd FASTQ_DIR
sh /cluster/home/futing/pipeline/fq2bigwig_v1.sh $FASTQ_DIR 523_atac