#!/bin/bash
#SBATCH -J res
#SBATCH --output=./split_%j.log
#SBATCH --cpus-per-task=5

python_path='/cluster/home/futing/Project/GBM/Corigami/corigami_data/data/hg38/gbm/hic_matrix/res.py'

python $python_path