#!/bin/bash

# loop bedpe 和 enhancer bed 取交集，得到intersect.bedpe
# Epre_bash.py调用

name=$1
workdir=/cluster/home/futing/Project/GBM/HiC/10loop/consensus/merged/flank0k
resultdir=/cluster/home/futing/Project/GBM/HiC/10loop/consensus/cytoscape

loopbed=${workdir}/${name}_flank0k.bedpe
enbed=/cluster/home/futing/Project/GBM/HiC/hubgene/new/chip/merge/${name}.merge_BS_detail.bed
pairToBed -a $loopbed -b $enbed > ${resultdir}/${name}/${name}_intersect.bedpe

