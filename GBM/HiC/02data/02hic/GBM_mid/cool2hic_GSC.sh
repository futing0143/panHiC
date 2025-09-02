#!/bin/bash
chrom_sizes=/cluster/home/futing/ref_genome/hg38.chrom.sizes
juicer_tools_jar=/cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar

for i in G523 G567 G583;do
    source activate ~/anaconda3/envs/hic
    cd /cluster/home/futing/Project/GBM/HiC/02data/02hic/${i}
    mcool_file=/cluster/home/futing/Project/GBM/HiC/02data/04mcool/01GBM/${i}.mcool
    #sh /cluster/home/futing/Project/GBM/HiC/02data/05file_transform/mcool2hic.sh ${mcool_file}
    java -Xmx200G -jar $juicer_tools_jar pre -j 20 ${i}.5000.bedpe.short.sorted ${i}.hic $chrom_sizes
done

for i in G523 G567 G583;do
    mkdir -p /cluster/home/futing/Project/GBM/HiC/02data/02hic/${i}
    cd /cluster/home/futing/Project/GBM/HiC/02data/02hic/${i}
    source activate ~/anaconda3/envs/juicer
    sh /cluster/home/futing/software/juicer_CPU/scripts/common/juicer_hiccups.sh \
        -j /cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar \
        -g hg38 -i ${i}.hic
done

#/cluster/home/futing/Project/GBM/HiC/10loop/hiccups/GBM/42MGBA/cool2hic_GSC.log