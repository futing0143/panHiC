#!/bin/bash
source activate ~/anaconda3/envs/juicer
cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/GBM_onedir
juicer_tools_path="/cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar"
for name in U343 U118 SW1088 A172 U87;do
    cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/GBM_onedir/
    export PATH=/cluster/apps/cuda/11.7/bin:$PATH
    export LD_LIBRARY_PATH=/cluster/apps/cuda/11.7/lib64:$LD_LIBRARY_PATH
    java -jar ${juicer_tools_path} hiccups --ignore-sparsity ${name}/aligned/inter_30.hic ${name}/aligned/inter_30_loops
    java -jar ${juicer_tools_path} apa ${name}/aligned/inter_30.hic ${name}/aligned/inter_30_loops ${name}/"apa_results"

done