#!/bin/bash

dir=$1
reso=${2:-5000}
win=${3:-25000}
name=$(basename ${dir})
source activate ~/miniforge3/envs/juicer
mkdir -p $dir/anno/insul && cd ${dir}/anno/insul
file=${dir}/cool/${name}_${reso}.cool


if cooler dump -t bins --header "$file" | head -1 | grep -qw "weight";then
	echo "[$(date)]$file is balanced"
	continue
else
	echo "[$(date)] ${file} is not ICE balanced!"
	cooler balance "$file"
fi

echo -e "\nProcessing $name at $reso using cooltools calling insulation..."


cooltools insulation $file $win -o ${name}_${reso}.tsv --ignore-diags 2 --verbose