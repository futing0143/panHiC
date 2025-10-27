#!/bin/bash

input=$1
bedfile=/cluster2/home/futing/Project/panCancer/PRAD/GSE249494/GSE249494_HiC_10000.bed


source activate /cluster2/home/futing/miniforge3/envs/juicer
name=$(basename ${input} | cut -d'_' -f2)
mkdir -p /cluster2/home/futing/Project/panCancer/PRAD/GSE249494/${name}/cool
cd /cluster2/home/futing/Project/panCancer/PRAD/GSE249494/${name}/cool

date
echo -e "Processing ${name} ...\n"
gunzip ${input}
# cooler cload pairix \
#     ${bed_file}:${input%.gz} \
#     ${name}_10000.cool
if [ ! -f ${name}_10000.cool ]; then
	echo -e "Creating ${name}_10000.cool ...\n"

	cooler load -f coo \
		--count-as-float \
		${bedfile} \
		${input%.gz} \
		${name}_10000.cool
else
	echo -e "${name}_10000.cool already exists, skipping creation.\n"
fi

cooler coarsen -k 5 ${name}_10000.cool -o ${name}_50000.cool
cooler coarsen -k 10 ${name}_10000.cool -o ${name}_100000.cool
cooler coarsen -k 50 ${name}_10000.cool -o ${name}_500000.cool



