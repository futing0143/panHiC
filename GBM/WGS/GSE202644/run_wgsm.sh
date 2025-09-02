#!/bin/bash


out1=/cluster/home/futing/Project/GBM/WGS/GSE202644/SRR19156791
out2=/cluster/home/futing/Project/GBM/WGS/GSE202644/SRR19156790
/cluster/home/futing/ref_genome/hg38_gencode/GATK/wgs_gvcf_to_vcf_20180509.sh \
	SRR19156791,SRR19156790 \
	/cluster/home/futing/Project/GBM/WGS/GSE202644 \
	GBM
