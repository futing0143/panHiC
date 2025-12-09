#!/bin/bash

dir=$1
reso=${2:-50000}
name=$(basename ${dir})

cd $dir # /cluster/home/futing/Project/panCancer/CRC/GSE178593/DLD-1
source activate ~/miniforge3/envs/stripenn
# mkdir -p ./anno/stripenn # 不用，因为会自动创建
if [[ ! -f ./anno/stripenn/result_filtered.tsv ]]; then
	echo "./anno/stripenn/result_filtered.tsv doesn't exists, removing it."
	rm -rf ./anno/stripenn
fi

stripenn compute --cool ./cool/${name}_${reso}.cool \
	--out ./anno/stripenn -k all -m 0.95,0.96,0.97,0.98,0.99 \
	--norm weight
