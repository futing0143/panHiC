#!/bin/bash
#SBATCH -J split
#SBATCH --output=./split_%j.log
#SBATCH --cpus-per-task=5

python_path='/cluster/home/futing/Project/GBM/Corigami/corigami_data/data/hg38/gbm/hic_matrix/split_cool.py'

python $python_path
