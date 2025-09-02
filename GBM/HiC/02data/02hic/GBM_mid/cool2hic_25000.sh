#!/bin/bash

# convert mcool to hic

cd /cluster/home/futing/Project/GBM/HiC/02data/02hic/GSC_split
resolutions=(5000 10000) # 25000
res=25000
#cat names.txt | while read name;do
for name in G120;do
    mkdir -p /cluster/home/futing/Project/GBM/HiC/02data/02hic/GSC_split/${res}
    cool_file="/cluster/home/futing/Project/GBM/HiC/02data/03cool/${res}/${name}_${res}.cool"
    txt_file="./${res}/${name}_${res}.txt"

    #01 cool 2 txt
    echo -e "Processing ${name} at ${res} resolution"
    source activate ~/anaconda3/envs/hic
    python /cluster/home/futing/Project/GBM/HiC/02data/05file_transform/cool2hic.py -i $cool_file -r $res -o $txt_file
    gzip ./${res}/${name}_${res}.txt ./${res}/${name}_${res}.txt.gz

    #02 txt 2 hic
    source activate ~/anaconda3/envs/juicer
    java -Xmx16G -jar /cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar pre \
        -j 20 --threads 30 -r ${res} -d ./${res}/${name}_${res}.txt.gz \
        ./${res}/${name}.hic /cluster/home/futing/ref_genome/hg38.chrom.sizes

done
#G120