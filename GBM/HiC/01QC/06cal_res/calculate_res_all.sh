#!/bin/bash
#SBATCH -J calculate_res
#SBATCH --output=./calculate_res_%j.log 
#SBATCH --cpus-per-task=10

/cluster/home/futing/software/juicer-1.6/misc/calculate_map_resolution.sh \
/cluster/home/futing/Project/GBM/HiC/06correlation/txt2hic/merge/merge_all/ts543_ck_rep2/aligned/merged_nodups.txt \
50bp_all_new.txt
