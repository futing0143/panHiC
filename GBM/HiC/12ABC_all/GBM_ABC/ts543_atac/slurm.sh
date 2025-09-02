#!/bin/bash
#SBATCH -J atac
#SBATCH -N 1
#SBATCH -p normal
#SBATCH --output=atac.out
#SBATCH --error=atac.err
#SBATCH --mail-type=all
#SBATCH --mail-user=kalozzhou@163.com #change to your email address


source activate /cluster/home/jialu/miniconda3/envs/atacseq/
sh forbam.sh
