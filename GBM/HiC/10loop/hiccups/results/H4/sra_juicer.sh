#!/bin/bash

cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/H4
:<< 'END'
cat srr.txt | while read i;do
    name=${i}
    prefetch -p -X 60GB ${name}
    source activate /cluster/home/futing/anaconda3/envs/download
    echo -e "parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip"
    parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip

done
END

rename _1 _R1 *fastq.gz
rename _2 _R2 *fastq.gz
rename .R1 _R1 *fastq.gz
rename .R2 _R2 *fastq.gz  
mkdir fastq
mv *.fastq.gz ./fastq

source activate /cluster/home/futing/anaconda3/envs/juicer
/cluster/home/futing/software/juicer_CPU/scripts/juicer.sh \
-D /cluster/home/futing/software/juicer_CPU/ \
-d /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/H4 -g hg38 \
-p /cluster/home/futing/software/juicer_CPU/restriction_sites/hg38.genome \
-z /cluster/home/futing/software/juicer_CPU/references/hg38.fa -s Arima > juicer.log

source activate /cluster/home/futing/anaconda3/envs/hic
resolutions=(5000 10000 50000 100000 500000 1000000)
#01 hic 2 mcool
hicConvertFormat -m ./aligned/inter_30.hic --inputFormat hic --outputFormat cool -o /cluster/home/futing/Project/GBM/HiC/02data/04mcool/H4.mcool

#02 mcool 2 cool 2 KR
for resolution in "${resolutions[@]}";do
    python /cluster/home/futing/Project/GBM/HiC/02data/05file_transform/add_prefix_to_cool.py /cluster/home/futing/Project/GBM/HiC/02data/04mcool/H4.mcool::resolutions/${resolution}
    echo "Processing H4 at ${resolution}..."
    cooler dump --join /cluster/home/futing/Project/GBM/HiC/02data/04mcool/H4.mcool::resolutions/${resolution} | \
    cooler load --format bg2 /cluster/home/futing/ref_genome/hg38_24.chrom.sizes:${resolution} \
    - /cluster/home/futing/Project/GBM/HiC/02data/03cool/${resolution}/H4_${resolution}.cool
done

# 03 cool 2 KR
for resolution in "${resolutions[@]}";do
    if [ ! -d ../03cool_KR/${resolution} ]; then
        mkdir /cluster/home/futing/Project/GBM/HiC/02data/03cool_KR/${resolution}
    fi
    
    cd /cluster/home/futing/Project/GBM/HiC/02data/03cool
    echo -e "\n Processing H4 at ${resolution} resolution \n"
    hicCorrectMatrix correct --matrix  ./${resolution}/H4_${resolution}.cool  \
    --correctionMethod KR --outFileName  ../03cool_KR/${resolution}/H4.${resolution}.KR.cool \
    --filterThreshold -1.5 5.0 \
    --chromosomes chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chrX 
done