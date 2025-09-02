#!/bin/bash
cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/A172_CPU/aligned/re_pre
source /cluster/home/futing/miniforge-pypy3/etc/profile.d/conda.sh
conda activate juicer
genomePath=/cluster/home/futing/software/juicer_new/restriction_sites/hg38.genome
juiceDir=/cluster/home/futing/software/juicer_new
outputdir=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/A172_CPU/aligned/

${juiceDir}/scripts/common/juicer_tools pre -j 20 \
    -q 30 $outputdir/merged_nodups.txt $outputdir/test.hic $genomePath 
