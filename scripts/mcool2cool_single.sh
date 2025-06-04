#!/bin/bash

resolution=$1
mcool_dir=$2
target_dir=$3

#name=$(echo $(basename ${mcool_dir} -Arima-allReps-filtered.mcool) | cut -f2 -d '_')
name=$(basename ${mcool_dir} .mcool)
echo -e "Processing ${name} at ${resolution} resolution..."
~/miniforge-pypy3/envs/HiC/bin/python /cluster/home/futing/Project/GBM/HiC/02data/05file_transform/modifycool/add_prefix_to_cool.py \
	${mcool_dir}::resolutions/${resolution}

cooler dump --join ${mcool_dir}::resolutions/${resolution} | \
cooler load --format bg2 /cluster/home/futing/software/juicer_CPU/restriction_sites/hg38.genome:${resolution} \
- ${target_dir}/${name}_${resolution}.cool

cooler balance --max-iters 1000 --force ${target_dir}/${name}_${resolution}.cool
