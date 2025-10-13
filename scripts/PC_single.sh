#!/bin/bash

dir=$1
cd $dir
cell=$(awk -F '/' '{print $NF}' <<< ${dir})
source activate /cluster2/home/futing/miniforge3/envs/juicer
cooltools eigs-cis \
	--phasing-track /cluster2/home/futing/Project/panCancer/GBM/HiC/06compartment/cooltools_old/gc.txt \
	./cool/${cell}_100000.cool \
	--out-prefix ./anno/${cell}_cis_100k
	