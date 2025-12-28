#!/bin/bash

IFS=$'\t'
while read -r cancer gse cell srr;do
	echo -e "Checking ${cancer}/${gse}/${cell}...\n"
	dir=/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}
	if [ -f "${dir}/splits/${srr}.fastq.gz.sam" ] && [ ! -f "${dir}/splits/${srr}.fastq.gz.bam" ]; then
		echo -e "${cancer}\t${gse}\t${cell}\t${srr}" \
		>> /cluster2/home/futing/Project/panCancer/check/sam2bam/sam2bam_undone1207.txt
	elif [ ! -f "${dir}/splits/${srr}.fastq.gz.sam" ] && [ -f "${dir}/splits/${srr}.fastq.gz.bam" ]; then
		echo -e "${cancer}\t${gse}\t${cell}\t${srr}" \
		>> /cluster2/home/futing/Project/panCancer/check/sam2bam/sam2bam_done1207.txt
	fi

done < "/cluster2/home/futing/Project/panCancer/check/meta/panCan_down_sim.txt"