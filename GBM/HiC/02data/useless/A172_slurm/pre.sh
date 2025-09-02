#!/bin/bash
#SBATCH -J pre
#SBATCH --output=./A172_re_%j.log 
#SBATCH --cpus-per-task=15

outputdir=/cluster/home/futing/Project/GBM/HiC/00data/GBM/A172_rerun/aligned
site_file=/cluster/home/futing/software/juicer/restriction_sites/hg38_HindIII.txt
genomePath=/cluster/home/futing/software/juicer/restriction_sites/hg38.genome
/cluster/home/futing/software/juicer/scripts/juicer_tools pre \
-s $outputdir/inter.txt \
-g $outputdir/inter_hists.m \
-q 1 $outputdir/merged_nodups.txt $outputdir/inter.hic $genomePath
#-f $site_file 