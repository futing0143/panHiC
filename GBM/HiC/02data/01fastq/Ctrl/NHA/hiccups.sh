#!/bin/bash

cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/NHA
source  ~/miniforge-pypy3/bin/activate ~/miniforge-pypy3/envs/juicer

juicer_tools_path="/cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar"
java -Xmx200G -jar ${juicer_tools_path} AddNorm -j 20 /cluster/home/futing/Project/GBM/HiC/02data/01fastq/NHA/aligned/inter_30.hic

date
/cluster/home/futing/software/juicer_CPU/scripts/common/juicer_postprocessing.sh -j /cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools \
    -i /cluster/home/futing/Project/GBM/HiC/02data/01fastq/NHA/aligned/inter_30.hic -g hg38
echo -e "\nRunning HiCCUPS for ${name}...\n"


mkdir -p /cluster/home/futing/Project/GBM/HiC/10loop/hiccups/GBM/NHA
mv /cluster/home/futing/Project/GBM/HiC/02data/01fastq/NHA/aligned/inter_30_loops/* \
    /cluster/home/futing/Project/GBM/HiC/10loop/hiccups/GBM/NHA