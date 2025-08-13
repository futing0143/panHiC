#!/bin/bash
#SBATCH -J ctcf_norm
#SBATCH --output=./ctcf_norm_%j.log 
#SBATCH --cpus-per-task=20

data_path='/cluster/home/futing/Project/GBM/Corigami/corigami_data/data/hg38/T543/genomic_features'
bigwigCompare -b1 $data_path/T543_input_final.bw -b2 $data_path/T543_ip_final.bw -p 8 -o $data_path/ctcf_log2fc.bigwig
