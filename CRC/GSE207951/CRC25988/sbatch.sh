#!/bin/bash -l
#SBATCH -p normal
#SBATCH --cpus-per-task=15
#SBATCH --nodelist=node1
#SBATCH --output=/cluster2/home/futing/Project/panCancer/CRC/GSE207951/CRC25988/debug/CRC25988-%j.log
#SBATCH -J "CRC25988"
ulimit -s unlimited
ulimit -l unlimited

date
cd /cluster2/home/futing/Project/panCancer/CRC/GSE207951/CRC25988
# mv ./debug/SRR20082372_1.fastq.gz ./fastq/SRR20082372_R1.fastq.gz
# mv ./debug/SRR20082372_2.fastq.gz ./fastq/SRR20082372_R2.fastq.gz

bash /cluster2/home/futing/Project/panCancer/scripts/juicerv1.4.sh -d /cluster2/home/futing/Project/panCancer/CRC/GSE207951/CRC25988 -e mHiC -s "juicer" -j "-S merge"
date


# SBATCH --dependency=afterok:79923