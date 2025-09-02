#!/bin/bash
cooldir=/cluster/home/futing/Project/GBM/HiC/02data/03cool_order/1000
resolution=1000
cat /cluster/home/futing/Project/GBM/HiC/02data/03cool_order/1000/name.txt | while read name;do

    cooler dump --join ${cooldir}/${name}.cool | \
    cooler load --format bg2 /cluster/home/futing/ref_genome/hg38.genome:${resolution} \
    - ${cooldir}/${name}_${resolution}.cool

    cooler balance ${cooldir}/${name}_${resolution}.cool
done