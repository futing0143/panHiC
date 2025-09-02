#!/bin/bash
#SBATCH -p normal
#SBATCH -t 48:00:00
#SBATCH -N 1
#SBATCH --mem=16G
#SBATCH --cpus-per-task=1

#SBATCH --job-name=G523
#SBATCH --output=G523.%j.%N.txt
#SBATCH --error=G523.%j.%N.err

source ~/../jialu/miniconda3/etc/profile.d/conda.sh
conda activate EagleC

predictSV --hic-5k /cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/G523.mcool::/resolutions/5000 \
--hic-10k /cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/G523.mcool::/resolutions/10000  \
--hic-50k /cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/G523.mcool::/resolutions/50000 \
-O G523 -g hg38 --balance-type ICE --output-format NeoLoopFinder --prob-cutoff-5k 0.8 --prob-cutoff-10k 0.8 --prob-cutoff-50k 0.99999

###ICE需要先cooler balance
