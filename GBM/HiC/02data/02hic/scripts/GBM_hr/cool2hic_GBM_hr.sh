#!/bin/bash
date
cd /cluster/home/futing/Project/GBM/HiC/02data/02hic/scripts/GBM_hr
juicer_tools=/cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.1.9.9_jcuda.0.8.jar

# 01 pre
export LC_ALL=en_US.UTF-8
java -Djava.awt.headless=true -XX:+UseG1GC -XX:ParallelGCThreads=16 -Xmx800g -Xms500g -jar $juicer_tools pre \
    --threads 40 \
    /cluster/home/futing/Project/GBM/HiC/02data/02hic/GBM/GBM_5000.5000.bedpe.short.sorted \
    ./GBM_hr2.hic /cluster/home/futing/ref_genome/hg38.genome
date

# 02 hiccups
# try1 failed
export PATH=/cluster/apps/cuda/11.7/bin:$PATH
export LD_LIBRARY_PATH=/cluster/apps/cuda/11.7/lib64:$LD_LIBRARY_PATH
module load cuda/11.7
nvcc --version
java -Djava.awt.headless=true -XX:+UseG1GC -XX:ParallelGCThreads=16 -Xmx800g -Xms500g -jar $juicer_tools hiccups \
    ./GBM_hr2.hic \
    /cluster/home/futing/Project/GBM/HiC/02data/02hic/scripts/GBM_loops_re

# try2 failed
sh /cluster/home/futing/software/juicer_CPU/scripts/common/juicer_hiccups.sh \
    -j /cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar \
    -g hg38 -i ./GBM_hr2.hic
date

# try3 failed
java -jar /cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.2.20.00.jar hiccups \
    ./GBM_hr2.hic ./GBM_hr2_loops

# try4 success why????
java -jar /cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar hiccups \
    ./GBM_hr2.hic ./GBM_1030_loops

# try5 sucess why???? 
java -jar /cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar hiccups --cpu \
    --threads 20 \
    ./GBM_hr2.hic ./GBM_hr2_loops