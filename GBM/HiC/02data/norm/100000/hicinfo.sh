#!/bin/bash
cd /cluster/home/futing/Project/GBM/HiC/02data/03cool/100000
ls /cluster/home/futing/Project/GBM/HiC/02data/03cool/100000/ | while read i;do
    echo $i
    hicInfo -m $i >> hicinfo.txt
done