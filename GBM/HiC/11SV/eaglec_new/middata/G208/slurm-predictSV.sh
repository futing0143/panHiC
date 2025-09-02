#!/bin/bash
#SBATCH -p gpu
#SBATCH -t 48:00:00
#SBATCH -N 1
#SBATCH --mem=16G
#SBATCH --cpus-per-task=1

#SBATCH --job-name=predictSV
#SBATCH --output=predictSV.%j.%N.txt
#SBATCH --error=predictSV.%j.%N.err

source ~/../jialu/miniconda3/etc/profile.d/conda.sh
conda activate EagleC

predictSV --hic-5k /cluster/home/tmp/GBM/HiC/02data/03cool/5000/G208_5000.cool \
--hic-10k /cluster/home/tmp/GBM/HiC/02data/03cool/10000/G208_10000.cool  \
--hic-50k /cluster/home/tmp/GBM/HiC/02data/03cool/50000/G208_50000.cool \
-O G208 -g hg38 --balance-type ICE --output-format NeoLoopFinder --prob-cutoff-5k 0.8 --prob-cutoff-10k 0.8 --prob-cutoff-50k 0.99999

###ICE需要先cooler balance
