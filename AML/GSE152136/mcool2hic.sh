#!/bin/bash
#SBATCH -p normal
#SBATCH --cpus-per-task=10
#SBATCH --output=/cluster2/home/futing/Project/panCancer/AML/GSE152136/mcool2hic-%j.log
#SBATCH -J "AML"

mcooldir=$1

source activate ~/miniforge3/envs/juicer
bash /cluster2/home/futing/Project/panCancer/scripts/mcool2hic.sh \
	$mcooldir \
	10000