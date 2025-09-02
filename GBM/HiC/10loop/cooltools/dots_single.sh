#!/bin/bash
reso=$1
name=$2

source /cluster/home/futing/miniforge-pypy3/etc/profile.d/conda.sh
conda activate
conda activate HiC

mkdir -p /cluster/home/futing/Project/GBM/HiC/10loop/cooltools/results/$name
cd /cluster/home/futing/Project/GBM/HiC/10loop/cooltools/results/$name

if [ -f ./${name}_view_hg38.tsv ];then
    echo "${name}_view_hg38.tsv exists, skip..."
else
    python /cluster/home/futing/Project/GBM/HiC/10loop/cooltools/view_hg38.py \
        -i /cluster/home/futing/Project/GBM/HiC/02data/03cool_order/${reso}/${name}_${reso}.cool -n $name
fi


echo -e "\nProcessing $name at $reso..."
file=/cluster/home/futing/Project/GBM/HiC/02data/03cool_order/${reso}/${name}_${reso}.cool

echo -e "\nRunning expected-cis...\n"
cooltools expected-cis --nproc 10 -o ./expected.cis.${reso}.tsv \
    --view ./${name}_view_hg38.tsv ${file}

echo -e "\nRunning dots...\n"
cooltools dots --nproc 10 -o ./dots.${reso}.tsv --view ./${name}_view_hg38.tsv \
    ${file} ./expected.cis.${reso}.tsv 



if [ $? -eq 0 ]; then
    echo -e "\nCooltools finished successfully\n"
else
    echo "***! Problem while running Cooltools";
    exit 1
fi