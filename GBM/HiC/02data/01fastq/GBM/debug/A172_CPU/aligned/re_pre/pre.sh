#!/bin/bash
#SBATCH -J pre
#SBATCH --output=./pre_%j.log 
#SBATCH --cpus-per-task=15

outputdir=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/A172_CPU/aligned
site_file=/cluster/home/futing/software/juicer/restriction_sites/hg38_HindIII.txt
genomePath=/cluster/home/futing/ref_genome/hg38.genome
java -jar /cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.2.20.00.jar pre \
    -j 20 \
    -q 30 /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/A172_CPU/aligned/merged_nodups.txt \
    $outputdir/re_pre/inter_30_header.hic $genomePath
#-f $site_file 