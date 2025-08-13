#!/bin/bash
#SBATCH -J split
#SBATCH --output=./split_%j.log
#SBATCH --cpus-per-task=5

path='/cluster/home/futing/Project/GBM/Corigami/corigami_data/data/hg38/T543/hic_matrix/GBM_9reso.mcool'
output='/cluster/home/futing/Project/GBM/Corigami/corigami_data/data/hg38/T543/hic_matrix'
python split.py $path $output --no-balance
