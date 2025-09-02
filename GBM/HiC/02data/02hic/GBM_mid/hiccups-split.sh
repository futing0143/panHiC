#!/bin/bash

cd /cluster/home/futing/Project/GBM/HiC/02data/02hic/5000
juicer_tools_path="/cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar"
source activate ~/anaconda3/envs/juicer

cat /cluster/home/futing/Project/GBM/HiC/02data/02hic/names2.txt | while read name;do
    echo -e "\nRunning HiCCUPS for ${name}...\n"
    export PATH=/cluster/apps/cuda/11.7/bin:$PATH
    export LD_LIBRARY_PATH=/cluster/apps/cuda/11.7/lib64:$LD_LIBRARY_PATH
    java -jar ${juicer_tools_path} hiccups -r 5000 ${name}.hic ${name}"_loops"
    java -jar ${juicer_tools_path} apa ${name}.hic ${name}"_loops" "apa_results"
:<<'END'
    sh /cluster/home/futing/software/juicer_CPU/scripts/common/juicer_hiccups.sh \
        -j /cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar \
        -i ./${name}.hic -g hg38

END
done