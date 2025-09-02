#!/bin/bash
cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/A172_new
data_dir=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/A172_new
juicer_tools=/cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar
juiceDir=/cluster/home/futing/software/juicer_CPU
outputdir=${data_dir}/aligned
name=A172_2
mcool_dir=/cluster/home/futing/Project/GBM/HiC/02data/04mcool/01GBM/${name}.mcool
resolutions=(1000 5000 10000 25000 50000 100000 250000 500000 1000000 2500000)
target_dir=/cluster/home/futing/Project/GBM/HiC/02data/03cool_order

export LC_ALL=en_US.UTF-8 
# java -Djava.awt.headless=true -XX:+UseG1GC -XX:ParallelGCThreads=16 -Xmx512g -Xms200g -jar $juicer_tools pre \
#     --threads 30 -s $outputdir/inter_30.txt -g $outputdir/inter_30_hists.m \
#     -q 30 $outputdir/merged_nodups.txt $outputdir/inter_30.hic \
#     /cluster/home/futing/software/juicer_new/restriction_sites/hg38.genome

# ${juiceDir}/scripts/common/juicer_postprocessing.sh \
#     -j ${juiceDir}/scripts/common/juicer_tools \
#     -i ${outputdir}/inter_30.hic -m ${juiceDir}/references/motif -g hg38

# 02 hic2cool
date
echo -e "Converting hic to cool..."
hicConvertFormat -m ${outputdir}/inter_30.hic \
    --inputFormat hic --outputFormat cool \
    -o ${mcool_dir}

# 03 mcool2cool

for res in ${resolutions[@]};do
    date
    echo -e "Processing Atrocyte at ${res} resolution..."
    cooler balance $mcool_dir::resolutions/${res}
    /cluster/home/futing/Project/GBM/HiC/02data/05file_transform/mcool2cool_single.sh ${res} $mcool_dir $target_dir
done