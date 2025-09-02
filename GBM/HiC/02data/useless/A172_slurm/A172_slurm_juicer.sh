#!/bin/bash
source activate ~/anaconda3/envs/juicer

/cluster/home/futing/software/juicer/scripts/juicer.sh \
-D /cluster/home/futing/software/juicer/ \
-d /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/GBM_onedir/A172_slurm -g hg38 \
-p /cluster/home/futing/software/juicer/restriction_sites/hg38.genome \
-z /cluster/home/futing/software/juicer/references/hg38.fa -s MboI \
-y /cluster/home/futing/software/juicer/restriction_sites/hg38_MboI.txt