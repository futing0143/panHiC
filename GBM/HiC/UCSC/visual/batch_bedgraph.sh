#!/bin/bash
reso=100000
for name in GBM;do
    comfile=/cluster/home/tmp/GBM/HiC/06compartment/cooltools/$(($reso/1000))k/${name}_cis_$(($reso/1000))k.cis.vecs.tsv
    insulfile=/cluster/home/futing/Project/GBM/HiC/09insulation/50k_800k/result/${name}_insul.tsv
    sh /cluster/home/futing/Project/GBM/HiC/UCSC/visual/BedGraph.sh $name insulation $insulfile 50k
    sh /cluster/home/futing/Project/GBM/HiC/UCSC/visual/BedGraph.sh $name boundary $insulfile 50k
    sh /cluster/home/futing/Project/GBM/HiC/UCSC/visual/BedGraph.sh $name compartment $comfile 100k
done