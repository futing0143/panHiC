#!/bin/bash


# lk=https://sra-pub-run-odp.s3.amazonaws.com/sra/SRR25635620/SRR25635620
cd /cluster2/home/futing/Project/panCancer/Analysis/ABC/ATAC/GEO/new

while read -r name;do

	lk="https://sra-pub-run-odp.s3.amazonaws.com/sra/${name}/${name}"
	wget -c ${lk}

done < <(tail -n +4 'srr0119.txt')