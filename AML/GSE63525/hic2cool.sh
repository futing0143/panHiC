#!/bin/bash


source activate ~/miniforge3/envs/mustache
dir=/cluster2/home/futing/Project/panCancer/AML/GSE63525/GM12878/cool
cell=GM12878
resolutions=(1000 5000 10000 25000 50000 100000 250000 500000 1000000 2500000)
# for reso in ${resolutions[@]}; do
# 	echo "[$(date)] Generating ${cell} at resolution ${reso}..."
# 	python ~/Project/panCancer/scripts/hic2cool_encode.py \
# 		/cluster2/home/futing/Project/panCancer/AML/GSE63525/GM12878/aligned/inter_30.hic ${reso} \
# 		/cluster2/home/futing/Project/panCancer/AML/GSE63525/GM12878/cool/GM12878_${reso}.cool
# 	echo "[$(date)] Balancing ${cell} at resolution ${reso}..."
# 	cooler balance --max-iters 1000 ${dir}/GM12878_${reso}.cool
# done

cooler zoomify \
	-r 4DN \
    -o ${dir}/${cell}.mcool \
    ${dir}/${cell}_1000.cool

for res in ${resolutions[@]}; do
	
	file=${dir}/${cell}.mcool::/resolutions/${res}
	echo "[$(date)] Checking ${file} is balanced"
	if cooler dump -t bins --header "$file" | head -1 | grep -qw "weight";then
		echo "$file is balanced"
		continue
	else
		echo "[$(date)] ${file} is not ICE balanced!"
		cooler balance --max-iters 1000 --force "$file"
	fi
done