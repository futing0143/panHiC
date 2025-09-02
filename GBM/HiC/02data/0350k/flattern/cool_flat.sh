#!/bin/bash

data_dir=/cluster/home/futing/Project/GBM/HiC/02data/0350k
find $name -name '*kr.ct.cool' |while read i;do
    name=$(basename $i _50k.kr.ct.cool)
    echo -e "Processing ${i} and ${name}"
    cooltools insulation $i -o ${data_dir}/${name}_insul.tsv  --ignore-diags 2 --verbose 800000
done 