#!/bin/bash

resolutions=(5000 10000 25000 50000 100000 250000 500000 1000000 2500000)
find /cluster/home/futing/Project/GBM/HiC/02data/04mcool/01GBM/EGA_re -name "*mcool" | while read i;do
    for resolution in "${resolutions[@]}";do
        echo -e "\n Processing ${i} at ${resolution} resolution \n"
        cooler balance ${i}::resolutions/${resolution}
    done
done

find /cluster/home/futing/Project/GBM/HiC/02data/04mcool/01GBM/ -maxdepth 1 -mindepth 1 -name "*mcool" | while read i;do
    for resolution in "${resolutions[@]}";do
        echo -e "\n Processing ${i} at ${resolution} resolution \n"
        cooler balance ${i}::resolutions/${resolution}
    done
done

for resolution in "${resolutions[@]}";do
    echo -e "\n Processing ${i} at ${resolution} resolution \n"
    cooler balance /cluster/home/futing/Project/GBM/HiC/02data/04mcool/02NPC/NPC_new.mcool::resolutions/${resolution}
done



for resolution in "${resolutions[@]}";do
    echo -e "\n Processing ${i} at ${resolution} resolution \n"
    cooler balance /cluster/home/futing/Project/GBM/HiC/02data/04mcool/04iPSC/iPSC_new.mcool::resolutions/${resolution}
done

:<<'END'
/cluster/home/futing/Project/GBM/HiC/02data/04mcool/04iPSC/iPSC_new.mcool::resolutions/2500000
/cluster/home/futing/Project/GBM/HiC/02data/04mcool/04iPSC/iPSC_new.mcool::resolutions/1000000
/cluster/home/futing/Project/GBM/HiC/02data/04mcool/04iPSC/iPSC_new.mcool::resolutions/500000
/cluster/home/futing/Project/GBM/HiC/02data/04mcool/01GBM/G567.mcool::resolutions/500000
/cluster/home/futing/Project/GBM/HiC/02data/04mcool/01GBM/G567.mcool::resolutions/250000
/cluster/home/futing/Project/GBM/HiC/02data/04mcool/01GBM/EGA_re/P521.SF12631.mcool::resolutions/100000
/cluster/home/futing/Project/GBM/HiC/02data/04mcool/01GBM/U87.mcool::resolutions/5000
END