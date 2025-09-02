#!/bin/bash
#SBATCH -J neoloopGB182
#SBATCH -N 1
#SBATCH -p normal
#SBATCH --output=neoGB182.out
#SBATCH --error=neoGB182.err
#SBATCH --mail-type=all
#SBATCH --mail-user=kalozzhou@163.com #change to your email address


source activate /cluster/home/jialu/miniconda3/envs/neoloop/
#sh cnv.sh 

assemble-complexSVs -O GB182 -B GB182.CNN_SVs.5K_combined.txt --balance-type ICE --protocol insitu --nproc 6 -H /cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/GB182.mcool::/resolutions/50000 /cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/GB182.mcool::/resolutions/10000 /cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/GB182.mcool::/resolutions/5000
neoloop-caller -O GB182.neo-loops.txt --assembly GB182.assemblies.txt --balance-type ICE --protocol insitu --prob 0.95 --nproc 4 -H /cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/GB182.mcool::/resolutions/50000 /cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/GB182.mcool::/resolutions/10000 /cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/GB182.mcool::/resolutions/5000
