#!/bin/bash
#SBATCH -J T543
#SBATCH --output=./fq2bw%j.log
#SBATCH --cpus-per-task=15

FASTQ_DIR="/cluster/home/futing/Project/GBM/Corigami/Training_data/GBM/TS543/ChIP/H3K4me3"
cd $FASTQ_DIR
fastq-dump --gzip --split-3 $FASTQ_DIR/SRR12056337.sralite
sh /cluster/home/futing/pipeline/fq2bigwig_v2.sh $FASTQ_DIR T543_H3K4me3
