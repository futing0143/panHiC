#!/bin/bash

export LC_ALL=C
export LC_COLLATE=C
juiceDir=/cluster/home/futing/software/juicer_CPU
splitdir=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U251/splits
outputdir=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U251/aligned
usegzip=1
read1str="_R1"
read2str="_R2"
ligation="GATCGATC"
i='SRR8446743_R1.fastq.gz'
ext=${i#*$read1str}
name=${i%$read1str*}
# these names have to be right or it'll break                     
name1=${name}${read1str}
name2=${name}${read2str}
jname=$(basename $name)${ext}


if [ "$usegzip" -eq 1 ]
then 
    num1=$(paste <(gunzip -c SRR8446743_R1.fastq.gz) <(gunzip -c SRR8446743_R2.fastq.gz) | awk '!((NR+2)%4)' | grep -cE $ligation)
    num2=$(gunzip -c SRR8446743_R1.fastq.gz | wc -l | awk '{print $1}')
else
    num1=$(paste $name1$ext $name2$ext | awk '!((NR+2)%4)' | grep -cE $ligation)
    num2=$(wc -l ${name1}${ext} | awk '{print $1}')
fi
echo -ne "$num1 " > ${name}${ext}_norm.txt.res.txt
echo "$num2" > ${name}${ext}_linecount.txt

ligation="AAGCTAGCTT"
num1=$(paste <(gunzip -c /cluster/home/hjwu/dfci/gbm_data/hic/fastq/ts667_kd_rep1_R1.fq.gz) \
    <(gunzip -c /cluster/home/hjwu/dfci/gbm_data/hic/fastq/ts667_kd_rep1_R2.fq.gz) | awk '!((NR+2)%4)' | grep -cE $ligation)