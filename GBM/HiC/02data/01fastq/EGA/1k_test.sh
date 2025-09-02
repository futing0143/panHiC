#!/bin/bash

cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA/P455.SF11901

java -jar /cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.2.20.00.jar pre \
    -j 20 -s ./aligned/inter_30.txt -g ./aligned/inter_30_hists.m \
    -q 30 ./aligned/merged_nodups.txt \
    ./aligned/test.hic /cluster/home/futing/ref_genome/hg38.genome