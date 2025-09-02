#!/bin/bash
#SBATCH -J atacGSC
#SBATCH -N 1
#SBATCH -p normal
#SBATCH --output=atacGSC.out
#SBATCH --error=atacGSC.err
#SBATCH --mail-type=all
#SBATCH --mail-user=kalozzhou@163.com #change to your email address


sh ATAC_v3.sh 50 no
