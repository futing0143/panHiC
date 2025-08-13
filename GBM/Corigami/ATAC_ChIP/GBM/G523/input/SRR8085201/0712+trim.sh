#!/bin/bash
#SBATCH -J G523trim
#SBATCH --output=./fq2bigwig_%j.log
#SBATCH --cpus-per-task=10

DATAPATH="/cluster/home/futing/Project/GBM/Corigami/Training_data/GBM/G523/input/SRR8085201"
cd $DATAPATH
#fastq-dump --gzip --split-3 --defline-qual '+' --defline-seq '@\$ac-\$si/\$ri' $DATAPATH
sh /cluster/home/futing/pipeline/fq2bigwig_v1.sh $DATAPATH G523_input
