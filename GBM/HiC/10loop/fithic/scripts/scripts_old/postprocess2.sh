#!/bin/bash
line=$1
res=${2}
cd /cluster/home/futing/Project/GBM/HiC/10loop/fithic

source /cluster/home/futing/miniforge-pypy3/etc/profile.d/conda.sh
conda activate hic


date
echo -e "\nProcessing ${line}...\n"

/cluster/home/futing/software/fithic/fithic/utils/merge-filter.sh \
    ./outputs/${res}/${line}.intraOnly/${line}.spline_pass1.res${res}.significances.txt.gz \
    ${res} ./outputs/${res}/${line}.intraOnly/${line}.merge.bed.gz 0.05 \
    /cluster/home/futing/software/fithic/fithic/utils/ > ./outputs/${res}/${line}.intraOnly/${line}.merge.log

