#!/bin/bash
#SBATCH -p gpu
#SBATCH --job-name=B_lymphocytes
#SBATCH --output=/cluster2/home/futing/Project/panCancer/Analysis/ABC/ATAC/GEO/B-ALL/GSE126113/B_lymphocytes/debug/B_lymphocytes_%j.log
#SBATCH --cpus-per-task=15
#SBATCH --nodelist=node3

script=/cluster2/home/futing/pipeline/newATAC/ATAC_v4.sh
dir=/cluster2/home/futing/Project/panCancer/Analysis/ABC/ATAC/GEO/B-ALL/GSE126113/B_lymphocytes
id=B_lymphocytes

echo "Start: $(date)"
bash ${script} -d ${dir} -n ${id} -s ${dir}/srr.txt -p yes
echo "End: $(date)"