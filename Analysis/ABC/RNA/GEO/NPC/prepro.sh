#!/bin/bash


RNAbed=/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/NPC/GSE268996_gene.TPM.matrix.annot.HK1.BOLF1.txt
cut -f1,8-10 $RNAbed | sed 's/\t/,/g'> NPC_TPM.csv