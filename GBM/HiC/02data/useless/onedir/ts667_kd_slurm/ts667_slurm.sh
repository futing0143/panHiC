#!/bin/bash

source /cluster/home/futing/miniforge-pypy3/bin/activate juicer

/cluster/home/futing/software/juicer/scripts/juicer.sh \
-D /cluster/home/futing/software/juicer \
-S final \
-d /cluster/home/futing/Project/GBM/HiC/02data/useless/onedir/ts667_kd_slurm -g hg38 \
-p /cluster/home/futing/software/juicer/restriction_sites/hg38.genome \
-z /cluster/home/futing/software/juicer/references/hg38.fa \
-s HindIII -t 20 -q gpu -l gpu