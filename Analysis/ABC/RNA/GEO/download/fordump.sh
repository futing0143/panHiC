#!/bin/bash


source activate ~/miniforge3/envs/RNA
cd /cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/download


# cat redump.txt | while read name;do
# date
# echo -e "parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip"
# parallel-fastq-dump --sra-id ./${name} --threads 40 --outdir ./ --split-3 --gzip
# date
# done

# for name in SRR9071976 SRR9071977;do
# date
# echo -e "parallel-fastq-dump --sra-id ${name}/${name}.lite --threads 40 --outdir ./ --split-3 --gzip"
# parallel-fastq-dump --sra-id ./${name}/${name}.lite --threads 40 --outdir ./ --split-3 --gzip
# date
# done

# IFS=$'\t'
# while read -r name;do
# date
# echo -e "parallel-fastq-dump --sra-id ${name}/${name} --threads 40 --outdir ./ --split-3 --gzip"
# parallel-fastq-dump --sra-id ./${name}/${name} --threads 40 --outdir ./ --split-3 --gzip
# date
# # done < <(sed -n '1,10p' ./dumperr0116.txt)
# done < <(sed -n '1,2p' ./dumperr0117.txt)

IFS=$'\t'
while read -r name;do
date
echo -e "parallel-fastq-dump --sra-id ${name}--threads 40 --outdir ./ --split-3 --gzip"
# export TMPDIR='/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/download/debug'
parallel-fastq-dump --sra-id ./${name} --threads 40 --outdir ./ --split-3 --gzip
date
# done < <(sed -n '11,14p' ./dumperr0116.txt)
# done < <(sed -n '3,7p' ./dumperr0117.txt)
done < "dumperr0117nig.txt"
