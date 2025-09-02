#!/bin/bash
#SBATCH -J OPC_fil
#SBATCH --output=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/snm3C/2019/opc_%j.log 
#SBATCH --cpus-per-task=20
#SBATCH --nodelist=node1

cooler dump --join /cluster/home/futing/Project/GBM/HiC/02data/01fastq/snm3C/2019/OPC_10000.cool | \
cooler load --format bg2 /cluster/home/futing/ref_genome/hg38.genome:10000 \
- /cluster/home/futing/Project/GBM/HiC/02data/01fastq/snm3C/2019/OPC_fil_10000.cool

cooler balance /cluster/home/futing/Project/GBM/HiC/02data/01fastq/snm3C/2019/OPC_fil_10000.cool