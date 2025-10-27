#!/bin/bash

hic_file_path=$1
loop_file=$2
juicer_tools_path=/cluster2/home/futing/software/juicer_CPU/scripts/common/juicer_tools

source activate /cluster2/home/futing/miniforge3/envs/juicer
${juicer_tools_path} apa ${hic_file_path} ${loop_file} "apa_results"
