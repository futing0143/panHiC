#!/bin/bash
#SBATCH --cpus-per-task=15
#SBATCH --output=/cluster2/home/futing/Project/panCancer/MEL/GSE248849/MNT-1_Hae3_Alu1/debug/MNT-1_Hae3_Alu1-%j.log
#SBATCH -J "MNT-1_Hae3_Alu1"

cd /cluster2/home/futing/Project/panCancer/MEL/GSE248849/MNT-1_Hae3_Alu1
source activate /cluster/home/futing/miniforge-pypy3/envs/HiC
splitdir="/cluster2/home/futing/Project/panCancer/MEL/GSE248849/MNT-1_Hae3_Alu1/splits"
outputdir="/cluster2/home/futing/Project/panCancer/MEL/GSE248849/MNT-1_Hae3_Alu1/aligned"
juiceDir="/cluster2/home/futing/software/juicer_CPU"
source ${juiceDir}/scripts/common/check.sh

sh /cluster2/home/futing/Project/panCancer/scripts/juicerv1.sh \
	-d /cluster2/home/futing/Project/panCancer/MEL/GSE248849/MNT-1_Hae3_Alu1 \
	-e Hae3_Alu1 \
	-s post