#!/bin/bash -l
#SBATCH -p normal
#SBATCH -t 5760
#SBATCH --cpus-per-task=20
#SBATCH --output=/cluster/home/futing/Project/GBM/HiC/10loop/fithic/debug/test-%j.log
#SBATCH -J "test"

# source activate HiC
source /cluster/home/futing/miniforge-pypy3/etc/profile.d/conda.sh

conda activate
conda activate HiC

which python
