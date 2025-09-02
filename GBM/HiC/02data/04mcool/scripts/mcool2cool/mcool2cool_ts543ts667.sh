#!/bin/bash

resolutions=(5000 10000 25000 50000 100000 250000 500000 1000000 2500000)

for name in ts543 ts667;do
    for reso in ${resolutions[@]};do
        echo "Processing ${reso} resolution..."
        mcool=/cluster/home/futing/Project/GBM/HiC/02data/04mcool/01GBM/${name}.mcool

        bash /cluster/home/futing/Project/GBM/HiC/02data/05file_transform/mcool2cool_single.sh \
            ${reso} ${mcool}
    done
done