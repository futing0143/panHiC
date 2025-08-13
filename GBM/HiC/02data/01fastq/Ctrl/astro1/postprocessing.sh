#!/bin/bash
hicdir=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/astro1
outputdir=${hicdir}/aligned

export PATH=/cluster/apps/cuda/10.2/bin:$PATH
export LD_LIBRARY_PATH=/cluster/apps/cuda/10.2/lib64:$LD_LIBRARY_PATH

/cluster/home/futing/software/juicer_CPU/scripts/common/juicer_postprocessing.sh \
    -j /cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools \
    -i ${outputdir}/inter_30.hic -m ${juiceDir}/references/motif -g hg38

# APA 有问题
hic_file_path=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/astro1/aligned/inter_30.hic
/cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools apa \
    ${hic_file_path} ${hic_file_path%.*}"_loops/merged_loops.bedpe" "apa_results"