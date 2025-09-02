#!/bin/bash
source activate ~/anaconda3/envs/juicer
cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U251

juicer_tools_path=/cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar
export PATH=/cluster/apps/cuda/11.7/bin:$PATH
export LD_LIBRARY_PATH=/cluster/apps/cuda/11.7/lib64:$LD_LIBRARY_PATH
java -jar ${juicer_tools_path} hiccups --ignore-sparsity ./aligned/inter_30.hic ./aligned/inter_30_loops
java -jar ${juicer_tools_path} apa ./aligned/inter_30.hic ./aligned/inter_30_loops ./"apa_results"
