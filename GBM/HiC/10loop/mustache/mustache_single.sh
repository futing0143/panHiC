#!/bin/bash
reso=$1
name=$2

source /cluster/home/futing/miniforge-pypy3/etc/profile.d/conda.sh
conda activate
conda activate HiC

mkdir -p /cluster/home/futing/Project/GBM/HiC/10loop/mustache/${reso}


cd /cluster/home/futing/Project/GBM/HiC/10loop/mustache/${reso}
file=/cluster/home/futing/Project/GBM/HiC/02data/03cool_order/${reso}/${name}_${reso}.cool

kb_reso=$((reso / 1000))kb
mustache -f $file -pt 0.05 -st 0.8 -r ${kb_reso} -norm weight -o ${name}_${kb_reso}_mustache.tsv
sed '1d' ${name}_${kb_reso}_mustache.tsv > ${name}_${kb_reso}_mustache.bedpe
rm ${name}_${kb_reso}_mustache.tsv

if [ $? -eq 0 ]; then
    echo -e "\nMustache for ${name} finished successfully\n"
else
    echo "***! Problem while running Mustache";
    exit 1
fi