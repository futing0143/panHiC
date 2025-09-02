#!/bin/bash
#SBATCH -J atacWTC
#SBATCH -N 1
#SBATCH -p normal
#SBATCH --output=atacWTC.out
#SBATCH --error=atacWTC.err
#SBATCH --mail-type=all
#SBATCH --mail-user=kalozzhou@163.com #change to your email address


sh ATAC_v3.sh 50 no
