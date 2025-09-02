#!/bin/bash

datadir=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U87/splits
fasta=/cluster/home/futing/ref_genome/hg38_gencode/bwa/hg38.fa
GATK_bundle=/cluster/home/futing/ref_genome/hg38_gencode/GATK/bundle
MboI=/cluster/home/futing/software/juicer_CPU/restriction_sites/hg38_MboI.txt
juicer=/cluster/home/futing/Project/GBM/HiCQTL/run_gatk_after_juicer.sh

mkdir /cluster/home/futing/Project/GBM/HiCQTL/U87
cd /cluster/home/futing/Project/GBM/HiCQTL/U87

for i in SRR11342203 SRR11342204 SRR11342205 SRR11342206;do
	bamfile=${datadir}/${i}.fastq.gz.bam
	$juicer -r ${fasta} \
		--gatk-bundle ${GATK_bundle} \
		--restriction-site-file ${MboI} \
		-t 20 \
		${bamfile} 
done
