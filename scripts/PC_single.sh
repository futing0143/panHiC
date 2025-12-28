#!/bin/bash

dir=$1
cd $dir
cell=$(basename ${dir})
source activate /cluster2/home/futing/miniforge3/envs/juicer

file=${dir}/cool/${cell}_100000.cool
if cooler dump -t bins --header "$file" | head -1 | grep -qw "weight";then
	echo "[$(date)]$file is balanced"
	continue
else
	echo "[$(date)] ${file} is not ICE balanced!"
	cooler balance "$file"
fi

echo "[$(date)] Calculating PC for ${cell} at 100k resolution..."
cooltools eigs-cis \
	--phasing-track /cluster2/home/futing/Project/panCancer/scripts/gc.txt \
	./cool/${cell}_100000.cool \
	--out-prefix ./anno/${cell}_cis_100k
	