#!/bin/bash
#SBATCH -J neoloop
#SBATCH -N 1
#SBATCH -p normal
#SBATCH --output=neo.out
#SBATCH --error=neo.err
#SBATCH --mail-type=all
#SBATCH --mail-user=kalozzhou@163.com #change to your email address


source activate /cluster/home/jialu/miniconda3/envs/neoloop/
#sh cnv.sh 

assemble-complexSVs -O P455.SF11901 -B P455.SF11901.CNN_SVs.5K_combined.txt --balance-type ICE --protocol insitu --nproc 6 -H /cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/EGA_re/P455.SF11901.mcool::/resolutions/50000 /cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/EGA_re/P455.SF11901.mcool::/resolutions/10000 /cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/EGA_re/P455.SF11901.mcool::/resolutions/5000
neoloop-caller -O P455.SF11901.neo-loops.txt --assembly P455.SF11901.assemblies.txt --balance-type ICE --protocol insitu --prob 0.95 --nproc 4 -H /cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/EGA_re/P455.SF11901.mcool::/resolutions/50000 /cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/EGA_re/P455.SF11901.mcool::/resolutions/10000 /cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/EGA_re/P455.SF11901.mcool::/resolutions/5000
