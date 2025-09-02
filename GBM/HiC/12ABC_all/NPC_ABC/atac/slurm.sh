#!/bin/bash
#SBATCH -J atacNPC
#SBATCH -N 1
#SBATCH -p normal
#SBATCH --output=atacNPC.out
#SBATCH --error=atacNPC.err
#SBATCH --mail-type=all
#SBATCH --mail-user=kalozzhou@163.com #change to your email address


sh ATAC_v3.sh "" no
