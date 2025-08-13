#!/bin/bash
#SBATCH -J split_
#SBATCH --output=./split_%j.log
#SBATCH --cpus-per-task=5

path='/cluster/home/futing/Project/GBM/Corigami/corigami_data/data/hg38/npc/NPC.mcool'
output='/cluster/home/futing/Project/GBM/Corigami/corigami_data/data/hg38/npc/hic_matrix'
python /cluster/home/futing/Project/GBM/Corigami/corigami_data/data/hg38/gbm/hic_matrix/split.py $path $output --no-balance
