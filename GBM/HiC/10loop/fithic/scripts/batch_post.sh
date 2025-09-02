#!/bin/bash

cat /cluster/home/futing/Project/GBM/HiC/10loop/fithic/scripts/name_chr.txt | while read name;do
    sh /cluster/home/futing/Project/GBM/HiC/10loop/fithic/scripts/fithic_single.sh 10000 $name no 0.1 yes yes
    sh /cluster/home/futing/Project/GBM/HiC/10loop/fithic/scripts/fithic_single.sh 5000 $name no 0.1 yes yes
done

cat /cluster/home/futing/Project/GBM/HiC/10loop/fithic/scripts/name_nochr.txt | while read name;do
    sh /cluster/home/futing/Project/GBM/HiC/10loop/fithic/scripts/fithic_single.sh 10000 $name no 0.1 no yes
    sh /cluster/home/futing/Project/GBM/HiC/10loop/fithic/scripts/fithic_single.sh 5000 $name no 0.1 no yes
done

cat /cluster/home/futing/Project/GBM/HiC/10loop/fithic/scripts/name_nochr_con.txt | while read name;do
    sh /cluster/home/futing/Project/GBM/HiC/10loop/fithic/scripts/fithic_single.sh 10000 $name no 0.1 no yes
    sh /cluster/home/futing/Project/GBM/HiC/10loop/fithic/scripts/fithic_single.sh 5000 $name no 0.1 no yes
done