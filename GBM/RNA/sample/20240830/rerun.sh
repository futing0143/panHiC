#!/bin/bash

# rerun grx part

fastq_dir='/cluster/home/futing/Project/GBM/RNA/sample/20240830/analysis/42MGBA/SRR25591307'
cd ${fastq_dir}
mv ${fastq_dir}/aligned ${fastq_dir}/aligned_0830
mv ${fastq_dir}/rsem_out ${fastq_dir}/rsem_out_0830
sh /cluster/home/futing/pipeline/RNA/rna_pe_part.sh ${fastq_dir}

# IFS=$'\t'
# while read -r cellline srr;do
# 	fastq_dir=/cluster/home/futing/Project/GBM/RNA/sample/20240830/analysis/${cellline}/${srr}
# 	cd ${fastq_dir}
# 	mv ${fastq_dir}/aligned ${fastq_dir}/aligned_0830
# 	mv ${fastq_dir}/rsem_out ${fastq_dir}/rsem_out_0830
# 	sh /cluster/home/futing/pipeline/RNA/rna_pe_part.sh ${fastq_dir}
# done < '/cluster/home/futing/Project/GBM/RNA/sample/20240830/pe.txt'