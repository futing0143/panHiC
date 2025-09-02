#!/bin/bash
cd  /cluster/home/futing/Project/GBM/HiC/12hichub
datadir=/cluster/home/futing/Project/GBM/HiC/02data/02hic
GBMhic=/cluster/home/futing/Project/GBM/HiC/02data/02hic/scripts/GBM_hr/GBM.hic
NPChic=${datadir}/Ctrl/NPC.hic
source activate HiC

mkdir -p ./GBMvsNPC
ln -s ${GBMhic} ./GBMvsNPC/GBM.hic
ln -s ${NPChic} ./GBMvsNPC/NPC.hic

# hichub convert -i ./GBMvsNPC -f GBM.hic,NPC.hic -l GBM,NPC -r 10000
hichub diff -i ./GBMvsNPC/Summary_GBM_NPC_Dense_Matrix.txt -l GBM,NPC -r 10000
hichub asso -i ./GBMvsNPC -l GBM,NPC -p /cluster/home/futing/ref_genome/hg38_gencode/GRCh38.promoter.bed
