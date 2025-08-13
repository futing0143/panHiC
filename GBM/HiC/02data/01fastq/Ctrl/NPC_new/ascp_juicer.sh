#!/bin/bash
:<< 'EOF'
prefetch -p -X 60GB --option-file srr.txt
for name in $(cat srr.txt);do
    source activate /cluster/home/futing/anaconda3/envs/download
    echo -e "parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip"
    parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip
done

mkdir fastq
find . -name "*.fastq.gz" -exec mv {} ./fastq \;
EOF

rename .R1 _R1 ./fastq/*fastq.gz
rename .R2 _R2 ./fastq/*fastq.gz
rename _1 _R1 ./fastq/*fastq.gz
rename _2 _R2 ./fastq/*fastq.gz
source activate /cluster/home/futing/anaconda3/envs/juicer
/cluster/home/futing/software/juicer_CPU/scripts/juicer.sh \
    -g hg38 \
    -d /cluster/home/futing/Project/GBM/HiC/02data/01fastq/NPC_new \
    -s Arima \
    -p /cluster/home/futing/software/juicer_CPU/restriction_sites/hg38.genome \
    -y /cluster/home/futing/software/juicer_CPU/restriction_sites/hg38_Arima.txt \
    -z /cluster/home/futing/software/juicer_CPU/references/hg38.fa \
    -D /cluster/home/futing/software/juicer_CPU/ > juicer.log 2>&1