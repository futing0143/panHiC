#!/bin/bash
resolutions=(5000 10000 50000 100000 500000 1000000)
#01 hic 2 mcool
cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U251
hicConvertFormat -m ./aligned/inter_30.hic --inputFormat hic --outputFormat cool -o U251.mcool

#02 mcool 2 cool 2 KR
for resolution in "${resolutions[@]}";do
    python /cluster/home/futing/Project/GBM/HiC/02data/05file_transform/add_prefix_to_cool.py U251.mcool::resolutions/${resolution}
    echo "Processing u251 at ${resolution}..."
    cooler dump --join U251.mcool::resolutions/${resolution} | \
    cooler load --format bg2 /cluster/home/futing/ref_genome/hg38_24.chrom.sizes:${resolution} \
    - /cluster/home/futing/Project/GBM/HiC/02data/03cool/${resolution}/U251_${resolution}.cool
done

# 03 cool 2 KR
for resolution in "${resolutions[@]}";do
    if [ ! -d ../03cool_KR/${resolution} ]; then
        mkdir /cluster/home/futing/Project/GBM/HiC/02data/03cool_KR/${resolution}
    fi
    
    cd /cluster/home/futing/Project/GBM/HiC/02data/03cool
    echo -e "\n Processing U251 at ${resolution} resolution \n"
    hicCorrectMatrix correct --matrix  ./${resolution}/U251_${resolution}.cool  \
    --correctionMethod KR --outFileName  ../03cool_KR/${resolution}/U251.${resolution}.KR.cool \
    --filterThreshold -1.5 5.0 \
    --chromosomes chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chrX 
done