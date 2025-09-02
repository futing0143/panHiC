#!/bin/bash
#SBATCH -J H3k27acWTC
#SBATCH -N 1
#SBATCH -p normal
#SBATCH --output=H3k27acWTC.out
#SBATCH --error=H3k27acWTC.err
#SBATCH --mail-type=all
#SBATCH --mail-user=kalozzhou@163.com #change to your email address


sh cut2rose_lite.sh histone "" "" "" ""
