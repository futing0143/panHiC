#!/bin/bash
#SBATCH -p gpu
#SBATCH --cpus-per-task=15
#SBATCH --nodelist=node2
#SBATCH --output=/cluster2/home/futing/Project/panCancer/Analysis/ABC/ATAC/GEO/B-ALL/GSE115482/NALM6/debug/NALM6-%j.log
#SBATCH -J "NALM6"
script=/cluster2/home/futing/pipeline/newATAC/ATAC_v4.sh
dir=/cluster2/home/futing/Project/panCancer/Analysis/ABC/ATAC/GEO/B-ALL/GSE115482/NALM6
id=NALM6
bash ${script} -d ${dir} \
 -n ${id} -s ${dir}/srr.txt