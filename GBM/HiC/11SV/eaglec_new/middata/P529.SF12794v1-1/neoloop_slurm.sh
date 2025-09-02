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

assemble-complexSVs -O P529.SF12794v1-1 -B P529.SF12794v1-1.CNN_SVs.5K_combined.txt --balance-type ICE --protocol insitu --nproc 6 -H /cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/EGA_re/P529.SF12794v1-1.mcool::/resolutions/50000 /cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/EGA_re/P529.SF12794v1-1.mcool::/resolutions/10000 /cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/EGA_re/P529.SF12794v1-1.mcool::/resolutions/5000
neoloop-caller -O P529.SF12794v1-1.neo-loops.txt --assembly P529.SF12794v1-1.assemblies.txt --balance-type ICE --protocol insitu --prob 0.95 --nproc 4 -H /cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/EGA_re/P529.SF12794v1-1.mcool::/resolutions/50000 /cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/EGA_re/P529.SF12794v1-1.mcool::/resolutions/10000 /cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/EGA_re/P529.SF12794v1-1.mcool::/resolutions/5000
