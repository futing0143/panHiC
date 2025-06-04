#!/bin/bash
dir=$1
reso=${2:-5000}
name=$(awk -F '/' '{print $NF}' <<< ${dir})

source activate HiC
file=${dir}/cool/${name}_${reso}.cool
mkdir -p $dir/anno/mustache
cd $dir/anno/mustache # /cluster/home/futing/Project/panCancer/CRC/GSE178593/DLD-1
echo -e "\nProcessing $name at $reso using mustache call dots..."


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