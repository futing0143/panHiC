#!/bin/bash

# convert mcool to hic

cd /cluster/home/futing/Project/GBM/HiC/02data/02hic
resolutions=(5000 10000) # 25000

cat names2.txt | while read name;do
    for res in ${resolutions[@]};do
        mkdir -p /cluster/home/futing/Project/GBM/HiC/02data/02hic/${res}
        cool_file="/cluster/home/futing/Project/GBM/HiC/02data/03cool/${res}/${name}_${res}.cool"
        txt_file="./${res}/${name}_${res}.txt"
        echo -e "Processing ${name} at ${res} resolution"
        #python /cluster/home/futing/Project/GBM/HiC/02data/05file_transform/cool2hic.py -i $cool_file -r $res -o $txt_file
        #gzip ./${res}/${name}_${res}.txt ./${res}/${name}_${res}.txt.gz
        source activate ~/anaconda3/envs/juicer
        java -Xmx16G -jar /cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar pre \
            -j 20 --threads 30 -r ${res} -d ./${res}/${name}_${res}.txt.gz \
            ./${res}/${name}.hic /cluster/home/futing/ref_genome/hg38.chrom.sizes
    done
done
