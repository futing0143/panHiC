#!/bin/bash

resolution=$1
mcool_file=$2
target_dir=$3

#name=$(echo $(basename ${mcool_file} -Arima-allReps-filtered.mcool) | cut -f2 -d '_')
name=$(basename ${mcool_file} .mcool)
echo -e "Processing ${name} at ${resolution} resolution..."
~/miniforge3/envs/juicer/bin/python /cluster2/home/futing/Project/panCancer/scripts/add_prefix_to_cool.py \
	${mcool_file}::resolutions/${resolution}

cooler dump --join ${mcool_file}::resolutions/${resolution} | \
cooler load --format bg2 /cluster2/home/futing/software/juicer_CPU/restriction_sites/hg38.genome:${resolution} \
- ${target_dir}/${name}_${resolution}.cool

cooler balance --max-iters 1000 --force ${target_dir}/${name}_${resolution}.cool
