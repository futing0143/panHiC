#!/bin/bash

for name in A172 U343 U87 U118 SW1088;do
    mkdir -p /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/${name}/fastq
    find /cluster/home/futing/Project/GBM/HiC/02data/useless/GBM_split/${name}/ -type f -name '*fastq.gz*' \
        | xargs -I {} mv {} /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/${name}/splits
done


for name in ts543_ck ts543_kd;do
    find /cluster/home/futing/Project/GBM/HiC/02data/useless/ourdata_split/all/ -type f -name "${name}*fastq.gz*" \
        | xargs -I {} mv {} /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/ts543/${name}/splits
done

for name in ts667_ck ts667_kd;do
    find /cluster/home/futing/Project/GBM/HiC/02data/useless/ourdata_split/all/ -type f -name "${name}*fastq.gz*" \
        | xargs -I {} mv {} /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/ts667/${name}/splits
done
