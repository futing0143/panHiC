#!/bin/bash
cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/A172_new
cat srr.txt | while read i;do
    name=${i}
    prefetch -p -X 60GB ${name}
    source activate /cluster/home/futing/anaconda3/envs/download
    echo -e "parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip"
    parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip

done

mkdir fastq
find . -name "*.fastq.gz" -exec mv {} ./fastq \;
rename _1 _R1 ./fastq/*fastq.gz
rename _2 _R2 ./fastq/*fastq.gz
rename .R1 _R1 ./fastq/*fastq.gz
rename .R2 _R2 ./fastq/*fastq.gz  

source /cluster/home/futing/miniforge-pypy3/etc/profile.d/conda.sh
conda activate juicer
/cluster/home/futing/software/juicer_CPU/scripts/juicer.sh \
    -D /cluster/home/futing/software/juicer_CPU \
    -d /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/A172_new -g hg38 \
    -p /cluster/home/futing/ref_genome/hg38.genome \
    -z /cluster/home/futing/software/juicer_CPU/references/hg38.fa -s MboI