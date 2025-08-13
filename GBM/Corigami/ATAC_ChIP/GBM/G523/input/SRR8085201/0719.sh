#!/bin/bash
#SBATCH -J G523
#SBATCH --output=./fq2bigwig_%j.log
#SBATCH --cpus-per-task=10

REF_GENOME="/cluster/home/futing/ref_genome/GRCh38.fa"