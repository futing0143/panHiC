#!/bin/bash



dir=$1
reso=${2:-5000}
cell=$(basename $dir)
coolfile=${dir}/cool/${cell}_${reso}.cool

# cooler coarsen -k5 ${coolfile} ${dir}/anno/cool/${cell}_${implement_reso}.cool
source activate ~/miniforge3/envs/juicer
echo "[$(date)] Generating multi-resolution mcool for ${cell}..."
cooler zoomify \
    -r 5000,10000,25000,50000 \
    -o ${dir}/cool/${cell}_4reso.mcool \
    ${dir}/cool/${cell}_${reso}.cool


for res in 50000 25000 10000 5000; do
	
	file=${dir}/cool/${cell}_4reso.mcool::/resolutions/${res}
	echo "[$(date)] Checking ${file} is balanced"
	if cooler dump -t bins --header "$file" | head -1 | grep -qw "weight";then
		echo "$file is balanced"
		continue
	else
		echo "[$(date)] ${file} is not ICE balanced!"
		cooler balance --max-iters 1000 --force "$file"
	fi
done