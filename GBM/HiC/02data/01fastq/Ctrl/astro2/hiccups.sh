#!/bin/bash
cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/A172_2
export PATH=/cluster/apps/cuda/10.2/bin:$PATH
export LD_LIBRARY_PATH=/cluster/apps/cuda/10.2/lib64:$LD_LIBRARY_PATH

nvcc -V
juicer_tools_path="/cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar"
hicfile="/cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/A172_2/aligned/inter_30.hic"
sh /cluster/home/futing/software/juicer_CPU/scripts/common/juicer_hiccups.sh \
    -j ${juicer_tools_path} \
    -i ${hicfile} -g hg38

hic_file_path=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/astro2/aligned/inter_30.hic
java -jar /cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools_2.17.00.jar apa \
    ${hic_file_path} ${hic_file_path%.*}"_loops/merged_loops.bedpe" "apa_results"