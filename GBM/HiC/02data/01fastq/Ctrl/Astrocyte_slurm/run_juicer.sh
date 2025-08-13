#!/bin/bash
source /cluster/home/futing/miniforge-pypy3/etc/profile.d/conda.sh
conda activate juicer
cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/Astrocyte_slurm


#ln -s /cluster/home/futing/Project/GBM/HiC/02data/01fastq/Astrocyte/fastq fastq


/cluster/home/futing/software/juicer_slurm/scripts/juicer.sh \
    -S postproc \
    -D /cluster/home/futing/software/juicer_slurm/ \
    -d /cluster/home/futing/Project/GBM/HiC/02data/01fastq/Astrocyte_slurm -g hg38 \
    -p /cluster/home/futing/software/juicer_slurm/restriction_sites/hg38.genome \
    -z /cluster/home/futing/software/juicer_slurm/references/hg38.fa -s HindIII -t 30 -q normal -l normal

