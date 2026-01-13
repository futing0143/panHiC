#!/bin/bash

cd /cluster/home/futing/Project/GBM/HiC/13mutation/mutation
name=gbm_cptac_2021
awk 'BEGIN{OFS="\t"}NR>1{print $5,$6-1,$7,NR}' \
/cluster/home/futing/Project/GBM/HiC/13mutation/gbm_cptac_2021/data_mutations.txt > ${name}.bed
liftOver ${name}.bed /cluster2/home/futing/ref_genome/liftover/hg19ToHg38.over.chain \
    ${name}_hg38.bed ${name}_hg38.unmapped


