#!/bin/bash
data_dir='/cluster/home/futing/Project/GBM/HiC/02data/03cool/5000'
:<<'END'
while IFS= read -r line
do
    file=${data_dir}/${line}_5000.cool
    files+=("$file")
    echo $file
    #python /cluster/home/futing/Project/GBM/HiC/02data/05file_transform/test.py $file 
done < '/cluster/home/futing/Project/GBM/HiC/02data/03cool/problem2.txt'
cooler merge merged_5000p4.cool "${files[@]}"
END
cooler dump --join merged_5000p4.cool | \
cooler load --format bg2 /cluster/home/futing/ref_genome/hg38_24.chrom.sizes:5000 \
- /cluster/home/futing/Project/GBM/HiC/02data/03cool/merged_5000p41.cool

cooler merge GBM_5000.cool /cluster/home/futing/Project/GBM/HiC/02data/03cool/5000/42MGBA_5000.cool \
    ./merged_5000p41.cool ./merged_50000.cool ./merged_50000p2.cool ./merged_50000p3.cool