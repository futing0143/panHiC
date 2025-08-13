#!/bin/bash
#SBATCH -J bed2bw
#SBATCH --output=./bed2bw_%j.log
#SBATCH --cpus-per-task=10

#necessary file index

chromosize="/cluster/share/ref_genome/hg38/assembly/hg38.chrom.sizes"
path="/cluster/home/futing/Project/GBM/Corigami/Training"
bedGraphToBigWig ${path}/empty.bedGraph $chromosize ${path}/output.bigWig
