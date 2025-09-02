#!/bin/bash

target="/cluster/home/futing/Project/GBM/HiC/10loop/hiccups/GBM"
find /cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA_re -name 'inter_30_loops' -type d | while read dir;do
    echo -e "\nCopying results from ${dir}...\n"
    dirn=$(echo "$dir" | awk -F'/' '{print $11}')
    mkdir -p ${target}/${dirn}
    cp ${dir}/* /cluster/home/futing/Project/GBM/HiC/10loop/hiccups/GBM/${dirn}
done
mkdir -p ${target}/H4
cp /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/H4/aligned/inter_30_loops/* ${target}/H4
mkdir -p ${target}/42MGBA
cp /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/42MGBA/aligned/inter_30_loops/* ${target}/42MGBA
mkdir -p ${target}/iPSC
cp /cluster/home/futing/Project/GBM/HiC/02data/01fastq/ipsc/onedir/mega/aligned/inter_30_loops/* ${target}/iPSC
mkdir -p ${target}/iPSC_new
cp /cluster/home/futing/Project/GBM/HiC/02data/01fastq/iPSC_new/aligned/inter_30_loops/* ${target}/iPSC_new
mkdir -p ${target}/NPC
cp /cluster/home/futing/Project/GBM/HiC/02data/01fastq/NPC/mega/aligned/inter_30_loops/* ${target}/NPC
mkdir -p ${target}/NPC_new
cp /cluster/home/futing/Project/GBM/HiC/02data/01fastq/NPC_new/aligned/inter_30_loops/* ${target}/NPC_new
mkdir -p ${target}/pHGG
cp /cluster/home/futing/Project/GBM/HiC/02data/01fastq/pHGG/mega/aligned/inter_30_loops/* ${target}/pHGG

for name in astro1 astro2;do
    mkdir -p ${target}/${name}
    cp /cluster/home/futing/Project/GBM/HiC/02data/01fastq/${name}/aligned/inter_30_loops/*  ${target}/${name}
done

mkdir -p ${target}/A172_2
cp /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/A172_2/aligned/inter_30_loops/*  ${target}/A172_2
mkdir -p ${target}/GBM
cp /cluster/home/futing/Project/GBM/HiC/02data/02hic/scripts/GBM_hr/GBM_1030gpu_loops/* ${target}/GBM