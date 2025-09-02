#!/bin/bash

# convert mcool to hic

cd /cluster/home/futing/Project/GBM/HiC/02data/02hic
#resolutions=(5000 10000) # 25000
res=5000
#cat names.txt | while read name;do
cat /cluster/home/futing/Project/GBM/HiC/02data/02hic/name2.txt | while read name;do
    # mkdir -p /cluster/home/futing/Project/GBM/HiC/02data/02hic/${res}
    # cool_file="/cluster/home/futing/Project/GBM/HiC/02data/03cool/${res}/${name}_${res}.cool"
    # txt_file="./${res}/${name}_${res}.txt"
    date
    #01 cool 2 txt
    echo -e "Processing ${name} at ${res} resolution"
    #source activate ~/anaconda3/envs/hic
    #python /cluster/home/futing/Project/GBM/HiC/02data/05file_transform/cool2hic.py -i $cool_file -r $res -o $txt_file
    #gzip ./${res}/${name}_${res}.txt ./${res}/${name}_${res}.txt.gz

    #01 txt 2 hic

    java -Xmx100G -jar /cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar pre \
        --threads 20 -d /cluster/home/futing/Project/GBM/HiC/02data/02hic/GBM_mid/5000/${name}_${res}.txt.gz \
        /cluster/home/futing/Project/GBM/HiC/02data/02hic/GBM_hr/${name}.hic /cluster/home/futing/ref_genome/hg38.genome
        
done
date