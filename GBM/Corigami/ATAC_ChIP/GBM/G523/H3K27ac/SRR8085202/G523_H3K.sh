#!/bin/bash
#SBATCH -J atest
#SBATCH --output=./atac_pipeline_%j.log
#SBATCH --cpus-per-task=10

DATAPATH="/cluster/home/futing/Project/GBM/Corigami/Training_data/GBM/G523/H3K27ac/SRR8085202/"
cd $DATAPATH
fastq-dump --gzip --split-3 --defline-qual '+' --defline-seq '@\$ac-\$si/\$ri' $DATAPATH
sh /cluster/home/futing/Project/GBM/Corigami/Training_data/lft_pipeline/fq2bigwig_v2.sh $DATAPATH G523_H3K27ac
