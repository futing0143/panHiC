#!/bin/bash
#SBATCH -J neo
#SBATCH -N 1
#SBATCH -p normal
#SBATCH --output=neo.out
#SBATCH --error=neo.err
#SBATCH --mail-type=all
#SBATCH --mail-user=kalozzhou@163.com #change to your email address


source activate /cluster/home/jialu/miniconda3/envs/neoloop/
#sh cnv.sh 

assemble-complexSVs -O G213 -B G213.CNN_SVs.5K_combined.txt --balance-type ICE --protocol insitu --nproc 6 -H /cluster/home/tmp/GBM/HiC/02data/03cool/50000/G213_50000.cool /cluster/home/tmp/GBM/HiC/02data/03cool/10000/G213_10000.cool /cluster/home/tmp/GBM/HiC/02data/03cool/5000/G213_5000.cool
neoloop-caller -O G213.neo-loops.txt --assembly G213.assemblies.txt --balance-type ICE --protocol insitu --prob 0.95 --nproc 4 -H /cluster/home/tmp/GBM/HiC/02data/03cool/50000/G213_50000.cool /cluster/home/tmp/GBM/HiC/02data/03cool/10000/G213_10000.cool /cluster/home/tmp/GBM/HiC/02data/03cool/5000/G213_5000.cool
