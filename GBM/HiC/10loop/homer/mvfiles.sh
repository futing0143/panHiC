#!/bin/bash

cat /cluster/home/futing/Project/GBM/HiC/10loop/homer/scripts/done.txt | while read name;do
    cd /cluster/home/futing/Project/GBM/HiC/10loop/homer/${name}
    # mkdir ./5000
    # find ./TagDir -type f ! -name "*.tsv" -exec mv {} ./5000 \;
    # find ./5000 -type f ! -name "TagDir*" -exec mv {} ./TagDir \;
    # rename TagDir ${name} 5000/*

    find /cluster/home/futing/Project/GBM/HiC/10loop/homer/${name}/TagDir -name "chr*_*" -delete
done
