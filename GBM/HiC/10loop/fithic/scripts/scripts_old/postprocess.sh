#!/bin/bash
res=$1
namelist=$2
cd /cluster/home/futing/Project/GBM/HiC/10loop/fithic
source /cluster/home/futing/miniforge-pypy3/etc/profile.d/conda.sh
conda activate hic

cat $namelist | while read line;do
    echo -e "\nProcessing ${line}...\n"
    #sh /cluster/home/futing/software/fithic/fithic/utils/createFitHiCHTMLout.sh \
    #${line} 1 ./outputs/${line}.intraOnly


    sh /cluster/home/futing/software/fithic/fithic/utils/merge-filter.sh \
    ./outputs/${res}/${line}.intraOnly/${line}.spline_pass1.res${res}.significances.txt.gz \
    ${res} ./outputs/${res}/${line}.intraOnly/${line}.merge.bed.gz 0.05 \
    /cluster/home/futing/software/fithic/fithic/utils/ > ./outputs/${res}/${line}.intraOnly/${line}.merge.log

    #sh /cluster/home/futing/software/fithic/fithic/utils/visualize-UCSC.sh \
    #./outputs/${line}.intraOnly/${line}.spline_pass1.res${res}.significances.txt.gz \
    #./outputs/${line}.intraOnly/${line}.bed 0.05
done

:<<'END'
# 测试一下 测试数据是没有问题的
sh /cluster/home/futing/software/fithic/fithic/utils/createFitHiCHTMLout.sh \
${line} 1 ./outputs/${line}


sh /cluster/home/futing/software/fithic/fithic/utils/merge-filter.sh \
    ./outputs/${line}/${line}.spline_pass1.res10000.significances.txt.gz \
    10000 ./outputs/${line}/${line}.merge.bed.gz 0.05 \
    /cluster/home/futing/software/fithic/fithic/utils/

sh /cluster/home/futing/software/fithic/fithic/utils/visualize-UCSC.sh \
    ./outputs/${line}/${line}.spline_pass1.res10000.significances.txt.gz \
    ./outputs/${line}/${line}.bed 0.05

END