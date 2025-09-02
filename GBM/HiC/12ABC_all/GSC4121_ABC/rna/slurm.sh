#!/bin/bash
#SBATCH -J rnaGSC4121
#SBATCH -N 1
#SBATCH -p normal
#SBATCH --output=rnaGSC4121.out
#SBATCH --error=rnaGSC4121.err
#SBATCH --mail-type=all
#SBATCH --mail-user=kalozzhou@163.com #change to your email address


sh 1trimer.sh
