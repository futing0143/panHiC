#!/bin/bash
cd /cluster/home/futing/Project/GBM/ChIP/H3K27ac/Johnson_H3K27ac

for name in G523 G567 G583;do
    mkdir -p $name
    cd $name
    accession=$(head -n 1 srr.txt)
    #/cluster/home/futing/pipeline/Ascp/ascp.sh ./srr.txt ./ 20M
    prefetch -p -X 60GB --option-file srr.txt
    for name in $(cat srr.txt);do
        source activate /cluster/home/futing/anaconda3/envs/download
        echo -e "parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip"
        parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip
    done

    echo -e "/n Processing ${name}.../n IP is ${accession} /n"
    find . -name "*.fastq.gz" -exec mv {} ./ \;
    /cluster/home/futing/pipeline/ChIP_CUTTAG/cut2rose_lite_v1.sh "" 30 "${accession}" rose ""
    cd ..
done