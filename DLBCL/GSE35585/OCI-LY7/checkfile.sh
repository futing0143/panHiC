#!/bin/bash
#SBATCH -J checkfile
#SBATCH --output=/cluster2/home/futing/Project/panCancer/DLBCL/GSE35585/OCI-LY7n k/checkfile_%j.log
#SBATCH --nodelist=node3
#SBATCH -p gpu
#SBATCH --cpus-per-task=2



cd /cluster2/home/futing/Project/panCancer/DLBCL/GSE35585/OCI-LY7
cat srr.txt | while read -r srr; do
	gunzip -t ./${srr}.fastq.gz
	if [ $? -ne 0 ]; then
		echo "${srr} error"
	else
		echo "${srr} ok"
	fi
done