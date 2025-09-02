#!/bin/bash
#SBATCH -J 42MGBAneoloop
#SBATCH -N 1
#SBATCH -p normal
#SBATCH --mail-type=all
#SBATCH --mail-user=kalozzhou@163.com #change to your email address


source activate /cluster/home/jialu/miniconda3/envs/neoloop/
#sh cnv.sh 

assemble-complexSVs -O 42MGBA -B 42MGBA.CNN_SVs.5K_combined.txt --balance-type ICE --protocol insitu --nproc 6 -H /cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/42MGBA.mcool::/resolutions/50000 /cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/42MGBA.mcool::/resolutions/10000 /cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/42MGBA.mcool::/resolutions/5000
neoloop-caller -O 42MGBA.neo-loops.txt --assembly 42MGBA.assemblies.txt --balance-type ICE --protocol insitu --prob 0.95 --nproc 4 -H /cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/42MGBA.mcool::/resolutions/50000 /cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/42MGBA.mcool::/resolutions/10000 /cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/42MGBA.mcool::/resolutions/5000
