#!/bin/bash
#SBATCH -J neoloopNPC
#SBATCH -N 1
#SBATCH -p normal
#SBATCH --output=neoNPC.out
#SBATCH --error=neoNPC.err
#SBATCH --mail-type=all
#SBATCH --mail-user=kalozzhou@163.com #change to your email address


source activate /cluster/home/jialu/miniconda3/envs/neoloop/
#sh cnv.sh 

assemble-complexSVs -O NPC -B NPC.CNN_SVs.5K_combined.txt --balance-type ICE --protocol insitu --nproc 6 -H /cluster/home/tmp/GBM/HiC/02data/04mcool/02NPC/NPC.mcool::/resolutions/50000 /cluster/home/tmp/GBM/HiC/02data/04mcool/02NPC/NPC.mcool::/resolutions/10000 /cluster/home/tmp/GBM/HiC/02data/04mcool/02NPC/NPC.mcool::/resolutions/5000
neoloop-caller -O NPC.neo-loops.txt --assembly NPC.assemblies.txt --balance-type ICE --protocol insitu --prob 0.95 --nproc 4 -H /cluster/home/tmp/GBM/HiC/02data/04mcool/02NPC/NPC.mcool::/resolutions/50000 /cluster/home/tmp/GBM/HiC/02data/04mcool/02NPC/NPC.mcool::/resolutions/10000 /cluster/home/tmp/GBM/HiC/02data/04mcool/02NPC/NPC.mcool::/resolutions/5000
