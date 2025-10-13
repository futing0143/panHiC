#!/bin/bash
dir=$1
reso=${2:-5000}
name=$(awk -F '/' '{print $NF}' <<< ${dir})

source activate /cluster2/home/futing/miniforge3/envs/juicer
mkdir -p $dir/anno/cooltools
cd $dir/anno/cooltools # /cluster/home/futing/Project/panCancer/CRC/GSE178593/DLD-1
file=${dir}/cool/${name}_${reso}.cool
echo -e "\nProcessing $name at $reso using cooltools call dots..."

# 01 view_hg38.py
if [ -f ./${name}_view_hg38.tsv ];then
    echo "${name}_view_hg38.tsv exists, skip..."
else
    /cluster2/home/futing/miniforge3/envs/juicer/bin/python \
		/cluster2/home/futing/Project/panCancer/scripts/view_hg38.py \
        -i ${file} -n $name
fi

# 02 expected-cis
echo -e "\nRunning expected-cis...\n"
cooltools expected-cis --nproc 10 -o ./expected.cis.${reso}.tsv \
    --view ./${name}_view_hg38.tsv ${file}

# 03 dots
echo -e "\nRunning dots...\n"
cooltools dots --nproc 10 -o ./dots.${reso}.tsv --view ./${name}_view_hg38.tsv \
    ${file} ./expected.cis.${reso}.tsv 


if [ $? -eq 0 ]; then
    echo -e "\nCooltools finished successfully\n"
else
    echo "***! Problem while running Cooltools";
    exit 1
fi