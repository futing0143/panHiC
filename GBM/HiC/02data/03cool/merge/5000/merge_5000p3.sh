#!/bin/bash

data_dir=/cluster/home/futing/Project/GBM/HiC/02data/03cool/5000
result_dir=/cluster/home/futing/Project/GBM/HiC/02data/03cool/5000_re
#python /cluster/home/futing/Project/GBM/HiC/02data/05file_transform/filter_chr.py $data_dir $result_dir
while IFS= read -r line
do
    file=${data_dir}/${line}_5000.cool
    files+=("$file")
    echo $file
    #python /cluster/home/futing/Project/GBM/HiC/02data/05file_transform/test.py $file 
done < '/cluster/home/futing/Project/GBM/HiC/02data/03cool/problem3.txt'
cooler merge merged_50000p3.cool "${files[@]}"

