#!/bin/bash
#SBATCH -J GSE1neo
#SBATCH -N 1
#SBATCH -p normal
#SBATCH --output=neo.out
#SBATCH --error=neo.err
#SBATCH --mail-type=all
#SBATCH --mail-user=kalozzhou@163.com #change to your email address


source activate /cluster/home/jialu/miniconda3/envs/neoloop/
#sh cnv.sh 

assemble-complexSVs -O G402 -B G402.CNN_SVs.5K_combined.txt --balance-type ICE --protocol insitu --nproc 6 -H /cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/GSE229962_RAW/G402.mcool::/resolutions/50000 /cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/GSE229962_RAW/G402.mcool::/resolutions/10000 /cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/GSE229962_RAW/G402.mcool::/resolutions/5000
neoloop-caller -O G402.neo-loops.txt --assembly G402.assemblies.txt --balance-type ICE --protocol insitu --prob 0.95 --nproc 4 -H /cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/GSE229962_RAW/G402.mcool::/resolutions/50000 /cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/GSE229962_RAW/G402.mcool::/resolutions/10000 /cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/GSE229962_RAW/G402.mcool::/resolutions/5000
