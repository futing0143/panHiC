#!/bin/bash
#SBATCH -J plotSV
#SBATCH -N 1
#SBATCH -p normal
#SBATCH --output=plotSV.out
#SBATCH --error=plotSV.err
#SBATCH --mail-type=all
#SBATCH --mail-user=kalozzhou@163.com #change to your email address


source activate /cluster/home/jialu/miniconda3/envs/EagleC
#download-pretrained-models 
##  located at /cluster/home/jialu/miniconda3/lib/python3.9/site-packages/eaglec/data

annotate-gene-fusion --sv-file mergeall.CNN_SVs.5K_combined_forgene.txt --output-file mergeall.CNN_SVs.gene-fusions.txt --buff-size 10000 --skip-rows 1 --ensembl-release 93 --species human

plot-interSVs --cool-uri ../juicer_hind3/mergeall.mcool::resolutions/1000000 --full-sv-file mergeall.CNN_SVs.5K_combined_forgene.txt --output-figure-name chr4-chr12.png -C chr4 chr12 --balance-type Raw --dpi 800 # panel A
plot-interSVs --cool-uri ../juicer_hind3/mergeall.mcool::resolutions/1000000 --full-sv-file mergeall.CNN_SVs.5K_combined_forgene.txt --output-figure-name chr4-chr8.png -C chr4 chr8 --balance-type Raw --dpi 800 # panel B
