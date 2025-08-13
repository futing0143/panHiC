#!/bin/bash
source /cluster/home/futing/miniforge-pypy3/etc/profile.d/conda.sh
cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/Astrocyte
# prefetch -p -X 60GB --option-file srr_encode.txt
# /cluster/home/futing/pipeline/Ascp/ascp.sh ./srr.txt ./ 20M
# conda activate RNA
# for name in $(cat srr_encode.txt);do

#     echo -e "parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip"
#     parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip
# done


# mkdir fastq
# find . -name "*.fastq.gz" -exec mv {} ./fastq \;
# rename .R1 _R1 ./fastq/*fastq.gz
# rename .R2 _R2 ./fastq/*fastq.gz
# rename _1 _R1 ./fastq/*fastq.gz
# rename _2 _R2 ./fastq/*fastq.gz

conda activate juicer
/cluster/home/futing/software/juicer_new/scripts/juicer.sh \
    -g hg38 \
    -S final \
    -d /cluster/home/futing/Project/GBM/HiC/02data/01fastq/Astrocyte \
    -s HindIII \
    -p /cluster/home/futing/ref_genome/hg38.genome \
    -z /cluster/home/futing/software/juicer_new/references/hg38.fa \
    -D /cluster/home/futing/software/juicer_new/