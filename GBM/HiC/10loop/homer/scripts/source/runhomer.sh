#!/bin/bash

mkdir /cluster/home/futing/Project/GBM/HiC/10loop/homer/GB182p2
cd /cluster/home/futing/Project/GBM/HiC/10loop/homer/GB182p2
fastq=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/GB182/fastq
name=GB182
#enzyme=HINDIII
index=/cluster/home/futing/ref_genome/hg38_gencode/bowtie2_24chr/hg38

# 01 convert fastq 2 sam
#homerTools trim -3 AAGCTAGCTT -mis 0 -matchStart 20 -min 20 ${fastq}/${name}_R1.fastq
#homerTools trim -3 AAGCTAGCTT -mis 0 -matchStart 20 -min 20 ${fastq}/${name}_R1.fastq

bowtie2 -p 20 -x $index -U ${fastq}/${name}_R1.fastq.trimmed > ./${name}_R1.sam
bowtie2 -p 20 -x $index -U ${fastq}/${name}_R2.fastq.trimmed > ./${name}_R2.sam

# 02 make tag directory
echo -e "Make tag directory..."
makeTagDirectory ./TagDir ${name}_R1.sam,${name}_R2.sam -genome hg38 -checkGC -tbp 1 \
    -restrictionSite AAGCTT -bowtiePE

# 03 find TADs and loops
findTADsAndLoops.pl find ./TagDir -cpu 10 -res 5000 \
	-window 15000 -genome hg38