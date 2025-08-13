#!/bin/bash
cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/NHA
java -Xmx64G -jar /cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar pre -n \
    -j 20 --threads 30 -d /cluster/home/futing/Project/GBM/HiC/02data/01fastq/NHA/aligned/merged_nodups.txt \
    NHA.hic /cluster/home/futing/software/juicer_CPU/restriction_sites/hg38.genome
        