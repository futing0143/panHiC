#!/bin/bash
#SBATCH -J chip_input
#SBATCH --output=./chip_pipeline_%j.log
#SBATCH --cpus-per-task=20

cd /cluster/home/futing/Project/GBM/Corigami/Training_data/TS543/ChIP/input/
sh /cluster/home/futing/Project/GBM/Corigami/Training_data/chip_lft.sh /cluster/home/futing/Project/GBM/Corigami/Training_data/TS543/ChIP/input T543_input