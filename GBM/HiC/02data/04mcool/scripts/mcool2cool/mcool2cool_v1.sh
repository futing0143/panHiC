#!/bin/bash

data_dir=/cluster/home/futing/Project/GBM/HiC/02data/04mcool/01GBM
#10k
for i in U343 U118 SW1088 A172 U87;do
    python /cluster/home/futing/Project/GBM/HiC/02data/05file_transform/add_prefix_to_cool.py ${data_dir}/${i}.mcool::resolutions/10000

    echo "Processing ${i} at 10000 resolution"
    cooler dump --join ${data_dir}/${i}.mcool::resolutions/10000 | \
    cooler load --format bg2 /cluster/home/futing/ref_genome/hg38_24.chrom.sizes:10000 \
    - /cluster/home/futing/Project/GBM/HiC/02data/03cool/10000/${i}_10000.cool

    # KR normalization
    hicCorrectMatrix correct --matrix /cluster/home/futing/Project/GBM/HiC/02data/03cool/10000/${i}_10000.cool \
    --correctionMethod KR --outFileName /cluster/home/futing/Project/GBM/HiC/02data/03cool_KR/10000/${i}.10000.KR.cool \
    --filterThreshold -1.5 5.0 \
    --chromosomes chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chrX 
done

#500k
for i in U343 U118 SW1088 A172 U87 GB180 GB182 GB183 GB176 GB238;do
    python /cluster/home/futing/Project/GBM/HiC/02data/05file_transform/add_prefix_to_cool.py ${data_dir}/${i}.mcool::resolutions/500000

    cooler dump --join ${data_dir}/${i}.mcool::resolutions/500000 | \
    cooler load --format bg2 /cluster/home/futing/ref_genome/hg38_24.chrom.sizes:500000 \
    - /cluster/home/futing/Project/GBM/HiC/02data/03cool/500000/${i}_500000.cool

    # KR normalization
    hicCorrectMatrix correct --matrix /cluster/home/futing/Project/GBM/HiC/02data/03cool/500000/${i}_500000.cool \
    --correctionMethod KR --outFileName /cluster/home/futing/Project/GBM/HiC/02data/03cool_KR/500000/${i}.500000.KR.cool \
    --filterThreshold -1.5 5.0 \
    --chromosomes chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chrX 
done

# 03 NPC 500k 没有cool文件  
cooler dump --join /cluster/home/futing/Project/GBM/HiC/02data/04mcool/02NPC/NPC.mcool::resolutions/500000 | \
    cooler load --format bg2 /cluster/home/futing/ref_genome/hg38_24.chrom.sizes:500000 \
    - /cluster/home/futing/Project/GBM/HiC/02data/03cool/500000/NPC_500000.cool