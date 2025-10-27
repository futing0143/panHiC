#!/bin/bash

dir=$1
reso=${2:-5000}
win=${3:-25000}
name=$(awk -F '/' '{print $NF}' <<< ${dir})
source activate juicer
mkdir -p $dir/anno/insul && cd ${dir}/anno/insul
file=${dir}/cool/${name}_${reso}.cool
echo -e "\nProcessing $name at $reso using cooltools calling insulation..."


cooltools insulation $file $win -o ${name}_${reso}.tsv --ignore-diags 2 --verbose