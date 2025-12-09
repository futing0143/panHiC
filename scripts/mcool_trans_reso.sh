#!/bin/bash



dir=$1
reso=${2:-5000}
cell=$(basename $dir)
coolfile=${dir}/cool/${cell}_${reso}.cool

# cooler coarsen -k5 ${coolfile} ${dir}/anno/cool/${cell}_${implement_reso}.cool
source activate ~/miniforge3/envs/juicer
echo "[$(date)] Generating multi-resolution mcool for ${cell}..."
cooler zoomify \
    -r 5000,10000,25000 \
    -o ${dir}/cool/${cell}_3reso.mcool \
    ${dir}/cool/${cell}_${reso}.cool

for res in 5000 10000 25000;do
	echo "[$(date)] Balancing ${cell} at resolution ${res}..."
	cooler balance --max-iters 1000 ${dir}/cool/${cell}_3reso.mcool::/resolutions/${res}
done
