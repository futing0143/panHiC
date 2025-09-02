#!/bin/bash
coolfile=/cluster/home/futing/Project/GBM/HiC/02data/03cool_order
genomePath=/cluster/home/futing/ref_genome/hg38_25.genome
juiceDir=/cluster/home/futing/software/juicer_CPU

mkdir -p $coolfile/1000
source /cluster/home/futing/miniforge-pypy3/etc/profile.d/conda.sh
conda activate hic

# cat /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/GBM.txt | while read name;do
#     date
#     echo -e "Processing $name...\n"
#     cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/${name}
#     outputdir=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/${name}/aligned

#     java -jar /cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar \
#         pre -j 20 -r 1000 -s $outputdir/inter_30.txt \
#         -g $outputdir/inter_30_hists.m -q 30 $outputdir/merged_nodups.txt $outputdir/1000.hic $genomePath

#     echo -e "Converting $name to cool format...\n"
#     hicConvertFormat -m $outputdir/1000.hic --inputFormat hic --outputFormat cool \
#         --chromosomeSizes /cluster/home/futing/ref_genome/hg38.genome \
#         -o $coolfile/1000/${name}_1000.cool
#     cooler balance $coolfile/1000/${name}_1000.cool
# done

for name in ts543 ts667;do
    date
    echo -e "Processing $name...\n"
    cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/${name}/mega
    outputdir=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/${name}/mega/aligned

    java -jar /cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar \
        pre -j 20 -r 1000 -s $outputdir/inter_30.txt \
        -g $outputdir/inter_30_hists.m -q 30 $outputdir/merged_nodups.txt $outputdir/1000.hic $genomePath

    echo -e "Converting $name to cool format...\n"
    hicConvertFormat -m $outputdir/1000.hic --inputFormat hic --outputFormat cool \
        --chromosomeSizes /cluster/home/futing/ref_genome/hg38.genome \
        -o $coolfile/1000/${name}_1000.cool
    cooler balance $coolfile/1000/${name}_1000.cool
done
