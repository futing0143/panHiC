#!/bin/bash
#SBATCH -p gpu
#SBATCH -t "5780"
#SBATCH --cpus-per-task=5
#SBATCH --output=/cluster2/home/futing/Project/panCancer/MCL/GSE147123/Granta/Granta-%j.log
#SBATCH -J "Granta"

dir=/cluster2/home/futing/Project/panCancer/MCL/GSE147123/Granta/splits
find ${dir} -name "*.txt.gz" | while read -r file;do
	gunzip $file
done

sh /cluster2/home/futing/Project/panCancer/MCL/sbatch.sh GSE147123 Granta MboI "-S merge"