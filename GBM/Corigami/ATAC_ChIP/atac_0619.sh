#!/bin/bash
#SBATCH -J atac
#SBATCH --output=./atac_pipeline_%j.log
#SBATCH --cpus-per-task=20

cd /cluster/home/futing/Project/GBM/Corigami/Training_data/TS543/ATAC/
sh //cluster/home/futing/Project/GBM/Corigami/Training_data/atac_lft.sh /cluster/home/futing/Project/GBM/Corigami/Training_data/TS543/ATAC TS543
