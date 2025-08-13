#!/bin/bash
#SBATCH -J ts667ip
#SBATCH --output=./download_%j.log
#SBATCH --cpus-per-task=10

prefetch --option-file /cluster/home/futing/Project/GBM/Corigami/Training_data/TS667/Chip/ip/SRR_Acc_List.txt \
--output-directory /cluster/home/futing/Project/GBM/Corigami/Training_data/TS667/Chip/ip/