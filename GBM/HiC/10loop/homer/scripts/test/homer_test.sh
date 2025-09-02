#!/bin/bash
#cool_file=/cluster/home/futing/Project/GBM/HiC/02data/03cool_order/10000/G208_10000.cool
hic_file=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/GB182/aligned/inter_30.hic
name=GB182
# 01 convert cool 2 homer
mkdir -p ${name}
#hicConvertFormat -m $hic_file --inputFormat hic --outputFormat homer -o ./${name}/${name}_hic.homer
#hicConvertFormat -m ./${name}/${name}.homer --inputFormat homer --outputFormat cool -o ./${name}/${name}.cool

# 02 make tag directory
#makeTagDirectory ${name} -format HiCsummary ./${name}/${name}.homer

makeTagDirectory GB182_test -format HiCsummary /cluster/home/futing/Project/GBM/HiC/10loop/homer/GB182.homer -tbp 1
findTADsAndLoops.pl find G182_test -cpu 10 -res 5000 \
	-window 15000 -genome hg38 -p /cluster/home/futing/software/homer/data/badRegions.bed
