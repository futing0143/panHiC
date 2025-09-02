#!/bin/bash
#SBATCH -J rnaWTC
#SBATCH -N 1
#SBATCH -p gpu
#SBATCH --output=rnaWTC.out
#SBATCH --error=rnaWTC.err
#SBATCH --mail-type=all
#SBATCH --mail-user=kalozzhou@163.com #change to your email address


sh 1trimer.sh
