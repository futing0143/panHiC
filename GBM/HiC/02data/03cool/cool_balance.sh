#!/bin/bash

resolutions=(5000 10000 25000 50000 100000 250000 500000 1000000 2500000)
cd /cluster/home/futing/Project/GBM/HiC/02data/03cool

cat name1.txt | while read i;do
    for resolution in "${resolutions[@]}";do
        echo -e "\n Processing ${i} at ${resolution} resolution \n"
        cooler balance ./${resolution}/${i}_${resolution}.cool
    done
done

