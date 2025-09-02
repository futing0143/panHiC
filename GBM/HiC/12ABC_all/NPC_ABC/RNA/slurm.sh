#!/bin/bash
#SBATCH -J rnaNPC
#SBATCH -N 1
#SBATCH -p normal
#SBATCH --output=rnaNPC.out
#SBATCH --error=rnaNPC.err
#SBATCH --mail-type=all
#SBATCH --mail-user=kalozzhou@163.com #change to your email address

source activate /cluster/home/jialu/miniconda3/envs/RNAseq
sh 1trimer.sh
