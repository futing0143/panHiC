#!/bin/bash
#SBATCH -p normal
#SBATCH --cpus-per-task=20
#SBATCH --output=/cluster2/home/futing/Project/panCancer/GBM/GSE241592/NHA/debug/NHA-%j.log
#SBATCH -J "NHA"
#SBATCH --dependency=afterok:75049:75048

sh /cluster2/home/futing/Project/panCancer/scripts/juicerv1.sh \
-d /cluster2/home/futing/Project/panCancer/GBM/GSE241592/NHA \
-e Arima \
-j "-S merge"

