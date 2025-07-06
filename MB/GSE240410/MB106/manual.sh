#!/bin/bash


source activate HiC

cd /cluster2/home/futing/Project/panCancer/MB/GSE240410/MB106/splits

tmpdir=/cluster2/home/futing/Project/panCancer/MB/GSE240410/MB106/HIC_tmp
name='SRR25592946'
ext='.fastq.gz'
sort -T $tmpdir --parallel=4 -k2,2d -k6,6d -k4,4n -k8,8n -k1,1n -k5,5n -k3,3n $name${ext}.frag.txt > $name${ext}.sort.txt

if [ $? -ne 0 ]; then
	echo -e "Error: juicer.sh failed to run successfully. Exiting script.\n" >&2
	exit 1
fi


sh /cluster2/home/futing/Project/panCancer/MB/sbatch.sh GSE240410 MB106 MboI "-S merge"
