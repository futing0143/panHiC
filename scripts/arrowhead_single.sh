#!/bin/bash

dir=$1
genomeID="hg38"
hic_file_path="${dir}/aligned/inter_30.hic"
juicer_tools_path=/cluster2/home/futing/software/juicer_CPU/scripts/common/juicer_tools
if [ ! -f ${hic_file_path} ]; then
	echo "[$(date)] Error: Hi-C file not found at ${hic_file_path}" >&2
	exit 1
fi
if [ ! -f "${dir}/anno/arrowhead/50000_blocks.bedpe" ];then
	echo -e "\nArrowhead:\n"
	${juicer_tools_path} arrowhead -r 50000 --ignore-sparsity ${hic_file_path} "${dir}/anno/arrowhead"
fi
