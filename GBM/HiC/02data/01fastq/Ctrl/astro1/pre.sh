#!/bin/bash
juicer_tools=/cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar
outputdir=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/Astrocyte/aligned
export LC_ALL=en_US.UTF-8 
java -Djava.awt.headless=true -XX:+UseG1GC -XX:ParallelGCThreads=16 -Xmx512g -Xms200g -jar $juicer_tools pre \
    --threads 30 -s $outputdir/inter_30.txt -g $outputdir/inter_30_hists.m \
    -q 30 $outputdir/merged_nodups.txt $outputdir/inter_30.hic \
    /cluster/home/futing/software/juicer_new/restriction_sites/hg38.genome
