#!/bin/bash
#SBATCH -J ts667
#SBATCH --output=./download_%j.log
#SBATCH --cpus-per-task=10

prefetch --option-file /cluster/home/futing/Project/GBM/Corigami/Training_data/TS667/Chip/input/input.txt \
--output-directory /cluster/home/futing/Project/GBM/Corigami/Training_data/TS667/Chip/input/