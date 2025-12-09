#!/bin/bash


source /cluster/home/chenglong/.bashrc
source activate /cluster/home/chenglong/miniconda3/envs/tag2rose
cd /cluster2/home/futing/Project/panCancer/CESC/PRJCA001242/cervical_epithelial_cell

mkdir -p fastqc
# fastqc ./fastq/*.fastq.gz -t 10 -o ./fastqc


multiqc -o ./ ./fastqc/*zip