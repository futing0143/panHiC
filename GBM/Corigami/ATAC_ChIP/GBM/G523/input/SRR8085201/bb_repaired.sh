#!/bin/bash
#SBATCH -J lft_repaired
#SBATCH --output=./repair_%j.log
#SBATCH --cpus-per-task=10

DATA="/cluster/home/futing/Project/GBM/Corigami/Training_data/GBM/G523/input/SRR8085201"
cd $DATA
sh /cluster/home/futing/anaconda3/envs/atac_seq/bin/repair.sh \
in=${DATA}/SRR8085201.R1.fastq.gz \
in2=${DATA}/SRR8085201.R2.fastq.gz \
out=${DATA}/SRR8085201_repaired.R1.fastq.gz
out2=${DATA}/SRR8085201_repaired.R2.fastq.gz