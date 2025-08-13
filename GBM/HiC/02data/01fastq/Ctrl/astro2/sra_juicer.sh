#!/bin/bash
cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/astro_new
data_dir=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/astro_new
rename .R1 _R1 ./fastq/*fastq.gz
rename .R2 _R2 ./fastq/*fastq.gz
rename _1 _R1 ./fastq/*fastq.gz
rename _2 _R2 ./fastq/*fastq.gz

# 01 run juicer
source /cluster/home/futing/miniforge-pypy3/etc/profile.d/conda.sh
conda activate juicer
/cluster/home/futing/software/juicer_CPU/scripts/juicer.sh \
    -D /cluster/home/futing/software/juicer_CPU \
    -d /cluster/home/futing/Project/GBM/HiC/02data/01fastq/astro_new -g hg38 \
    -p /cluster/home/futing/ref_genome/hg38.genome \
    -z /cluster/home/futing/software/juicer_CPU/references/hg38.fa -s MboI -t 20

# 01.1 run pre
juicer_tools=/cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar
outputdir=${data_dir}/aligned
export LC_ALL=en_US.UTF-8 
java -Djava.awt.headless=true -XX:+UseG1GC -XX:ParallelGCThreads=16 -Xmx512g -Xms200g -jar $juicer_tools pre \
    --threads 30 -s $outputdir/inter_30.txt -g $outputdir/inter_30_hists.m \
    -q 30 $outputdir/merged_nodups.txt $outputdir/inter_30.hic \
    /cluster/home/futing/software/juicer_new/restriction_sites/hg38.genome

# 02 hic2cool
echo -e "Converting hic to cool..."
hicConvertFormat -m ${outputdir}/inter_30.hic \
    --inputFormat hic --outputFormat cool \
    -o /cluster/home/futing/Project/GBM/HiC/02data/04mcool/Control/astro2.mcool

# 03 mcool2cool
mcool_dir=/cluster/home/futing/Project/GBM/HiC/02data/04mcool/Control/astro2.mcool
resolutions=(1000 5000 10000 25000 50000 100000 250000 500000 1000000 2500000)
target_dir=/cluster/home/futing/Project/GBM/HiC/02data/03cool_order
for res in ${resolutions[@]};do
    date
    echo -e "Processing Atrocyte at ${res} resolution..."
    cooler balance $mcool_dir::resolutions/${res}
    /cluster/home/futing/Project/GBM/HiC/02data/05file_transform/mcool2cool_single.sh ${res} $mcool_dir $target_dir
done

# 之前的有bug astrocyte名字写错了
# resolutions=(5000 10000 50000 100000 500000 1000000 25000 250000 2500000)
# for res in ${resolutions[@]};do
#     mv /cluster/home/futing/Project/GBM/HiC/02data/03cool_order/${res}/Astrocyte1_${res}.cool \
#         /cluster/home/futing/Project/GBM/HiC/02data/03cool_order/${res}/astro1_${res}.cool
# done

