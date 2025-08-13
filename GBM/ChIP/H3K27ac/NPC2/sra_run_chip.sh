#!/bin/bash

cd /cluster/home/futing/Project/GBM/ChIP/H3K27ac/NPC2

# prefetch -p -X 60GB --option-file srr.txt

sh /cluster/home/futing/pipeline/Ascp/ascp2.sh srr.txt ./ 20M
for name in $(cat srr.txt);do
    source activate /cluster/home/futing/anaconda3/envs/download
    echo -e "parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip"
    parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip
done

cat SRR17882750_1.fastq.gz SRR17882751_1.fastq.gz > input_1.fastq.gz
cat SRR17882750_2.fastq.gz SRR17882751_2.fastq.gz > input_2.fastq.gz



/cluster/home/futing/pipeline/ChIP_CUTTAG/cut2rose_lite_v1.2.sh "" 40 input rose "" filename.txt



# awk 'BEGIN{OFS="\t"} {print $1, $2, $3, $7}' /cluster/home/futing/Project/GBM/ChIP/H3K27ac/NPC/macs2/SRR22528424_peaks.narrowPeak > output.bedGraph
# # bedgragh 2 bigwigno
# LC_ALL=C sort -k1,1 -k2,2n output.bedGraph > sorted_output.bedGraph
# bedGraphToBigWig sorted_output.bedGraph /cluster/home/futing/ref_genome/hg38.chrom.sizes NPC_H3K27ac.bw
