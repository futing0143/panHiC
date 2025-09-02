#!/bin/bash
#SBATCH -J GBM_chr1and2
#SBATCH -N 1
#SBATCH -p gpu
#SBATCH --output=GBM_chr1and2.out
#SBATCH --error=GBM_chr1and2.err
#SBATCH --mail-type=all
#SBATCH --mail-user=kalozzhou@163.com #change to your email address


java -Xms1g -Xmx5g -jar /cluster/home/jialu/4DN_iPSc/pipeline/extra/juicer/scripts/common/juicer_tools_1.22.01.jar pre \
-r 10000  -q 1 10k_KR/GBM_10k.txt.gz 10k_KR/GBM_10k_chr1and2only.hic \
/cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/example_chr22/TCGAout/hg38.chrom.size \
-k KR -c chr1,chr2

