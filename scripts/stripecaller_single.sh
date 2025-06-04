#!/bin/bash


# XiaoTaoWang
dir=$1
reso=${2:-5000}
name=$(awk -F '/' '{print $NF}' <<< ${dir})

cd $dir # /cluster/home/futing/Project/panCancer/CRC/GSE178593/DLD-1
source activate HiC
if [ -z "$(ls -A $dir 2>/dev/null)" ]; then
    echo "$dir is empty. rm -rf ./anno/stripecaller"
	rm -rf ./anno/stripecaller
fi

call-stripes -p ./cool/${name}_${reso}.cool \
	-O ./anno/stripecaller \
	--nproc 10