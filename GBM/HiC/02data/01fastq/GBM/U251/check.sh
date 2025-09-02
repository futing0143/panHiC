#!/bin/bash

juiceDir=/cluster/home/futing/software/juicer_CPU
splitdir=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U251_CPU/splits
outputdir=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U251_CPU/aligned
cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U251_CPU
usegzip=1
read1str="_R1"
read2str="_R2"
ligation="GATCGATC"
for i in ${splitdir}/*_R1.fastq.gz;do
    ext=${i#*$read1str}
    name=${i%$read1str*}
    # these names have to be right or it'll break                     
    name1=${name}${read1str}
    name2=${name}${read2str}
    jname=$(basename $name)${ext}
    source ${juiceDir}/scripts/common/countligations.sh
done
source ${juiceDir}/scripts/common/check.sh