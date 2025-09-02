#!/bin/bash
cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/A172_2
# export PATH=/cluster/apps/cuda/11.7/bin:$PATH
# export LD_LIBRARY_PATH=/cluster/apps/cuda/11.7/lib64:$LD_LIBRARY_PATH

nvcc -V
juicer_tools_path="/cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar"
hicfile="/cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/A172_2/aligned/inter_30.hic"
sh /cluster/home/futing/software/juicer_CPU/scripts/common/juicer_hiccups.sh \
    -j ${juicer_tools_path} \
    -i ${hicfile} -g hg38