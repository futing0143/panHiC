#!/bin/bash

cd /cluster/home/futing/Project/GBM/HiC/02data/02hic/GBM
#juicer_tools_path="/cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.1.9.9_jcuda.0.8.jar"
juicer_tools_path="/cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar"
source activate ~/anaconda3/envs/juicer

#cat /cluster/home/futing/Project/GBM/HiC/02data/02hic/names4.txt | while read name;do
#for name in G457 G61 G62 G83;do
for name in G62;do
    if [[ -f ${name}.hic ]];then
        echo -e "\nRunning HiCCUPS for ${name}...\n"
        sh /cluster/home/futing/software/juicer_CPU/scripts/common/juicer_hiccups.sh \
            -j ${juicer_tools_path} \
            -i ${name}.hic -g hg38

    else
        echo "${name}.hic not found."
    fi
    mkdir -p /cluster/home/futing/Project/GBM/HiC/10loop/hiccups/GBM/${name}
    mv /cluster/home/futing/Project/GBM/HiC/02data/02hic/GBM/${name}_loops/* \
        /cluster/home/futing/Project/GBM/HiC/10loop/hiccups/GBM/${name}
done

:<<'END'

        export PATH=/cluster/apps/cuda/11.7/bin:$PATH
        export LD_LIBRARY_PATH=/cluster/apps/cuda/11.7/lib64:$LD_LIBRARY_PATH
        java -jar ${juicer_tools_path} hiccups ${name}.hic ${name}"_loops"
        java -jar ${juicer_tools_path} apa ${name}.hic ${name}"_loops" "apa_results"

END