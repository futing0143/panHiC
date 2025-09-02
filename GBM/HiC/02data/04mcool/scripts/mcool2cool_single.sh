#!/bin/bash

resolution=$1
mcool_dir=$2
#name=$(echo $(basename ${mcool_dir} -Arima-allReps-filtered.mcool) | cut -f2 -d '_')
name=$(basename ${mcool_dir} .mcool)
echo -e "Processing ${name} at ${resolution} resolution..."
python /cluster/home/futing/Project/GBM/HiC/02data/05file_transform/add_prefix_to_cool.py ${mcool_dir}::resolutions/${resolution}


# 之前的chrom.sizes是按照大小排序的
cooler dump --join ${mcool_dir}::resolutions/${resolution} | \
cooler load --format bg2 /cluster/home/futing/ref_genome/hg38.genome:${resolution} \
- /cluster/home/futing/Project/GBM/HiC/02data/03cool/${resolution}/${name}_${resolution}.cool

cooler balance /cluster/home/futing/Project/GBM/HiC/02data/03cool/${resolution}/${name}_${resolution}.cool


:<<'END'
# ICE normalization
hicCorrectMatrix correct --matrix /cluster/home/futing/Project/GBM/HiC/02data/03cool/${resolution}/${name}_${resolution}.cool \
--correctionMethod ICE --outFileName  /cluster/home/futing/Project/GBM/HiC/02data/ICE_cool/${resolution}/${name}.${resolution}.ICE.cool \
--filterThreshold -1.5 5.0 \
--chromosomes chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chrX 

hicCorrectMatrix correct --matrix /cluster/home/futing/Project/GBM/HiC/02data/03cool/5000/A172_5000.cool \
--correctionMethod KR --outFileName /cluster/home/futing/Project/GBM/HiC/02data/03cool/5000/A172_5000_balanced.cool \
--chromosomes chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chrX 
END