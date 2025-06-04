#!/bin/bash

dir=$1
cd $dir
cell=$(awk -F '/' '{print $NF}' <<< ${dir})
cooltools eigs-cis \
	--phasing-track /cluster/home/futing/Project/GBM/HiC/06compartment/cooltools_old/gc.txt \
	./cool/${cell}_100000.cool \
	--out-prefix ./anno/${cell}_cis_100k
	