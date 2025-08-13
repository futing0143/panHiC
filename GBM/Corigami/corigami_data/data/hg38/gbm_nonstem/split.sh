#!/bin/bash
#SBATCH -J splitnorm
#SBATCH --output=./split_%j.log
#SBATCH --cpus-per-task=5

path='/cluster/home/futing/Project/GBM/Corigami/corigami_data/data/hg38/gbm_norm/GBM_common.mcool'
output='/cluster/home/futing/Project/GBM/Corigami/corigami_data/data/hg38/gbm_norm/hic_matrix/'
python /cluster/home/futing/Project/GBM/Corigami/corigami_data/data/hg38/gbm/hic_matrix/split.py $path $output --no-balance
