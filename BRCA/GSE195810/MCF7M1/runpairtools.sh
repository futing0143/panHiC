#!/bin/bash
#SBATCH -p gpu
#SBATCH -J MCF7M1_pair
#SBATCH --cpus-per-task=15
#SBATCH -o /cluster2/home/futing/Project/panCancer/BRCA/GSE195810/MCF7M1/debug/MCF7M1_pair-%j.log

bash /cluster2/home/futing/Project/panCancer/BRCA/GSE195810/MCF7M1/runpairtools.sh \
	/cluster2/home/futing/Project/panCancer/BRCA/GSE195810/MCF7M1 5000 15 DpnII