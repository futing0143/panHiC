#!/bin/bash
#SBATCH -J wgs
#SBATCH -N 1
#SBATCH -p normal
#SBATCH --output=9.1mutect.out
#SBATCH --error=9.1mutect.err
#SBATCH --mail-type=all
#SBATCH --mail-user=kalozzhou@163.com #change to your email address

source ~/../haojie/miniconda3/etc/profile.d/conda.sh
conda activate wes
sh 9.1Funcotator.sh

