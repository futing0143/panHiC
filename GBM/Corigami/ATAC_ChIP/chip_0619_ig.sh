#!/bin/bash
#SBATCH -J chip_ip
#SBATCH --output=./chip_pipeline_%j.log
#SBATCH --cpus-per-task=20

cd /cluster/home/futing/Project/GBM/Corigami/Training_data/TS543/ChIP/ip/
sh /cluster/home/futing/Project/GBM/Corigami/Training_data/chip_lft.sh /cluster/home/futing/Project/GBM/Corigami/Training_data/TS543/ChIP/ip T543_ip