#!/bin/bash

# sh /cluster/home/futing/pipeline/RNA/rna_se.sh /cluster/home/futing/Project/GBM/RNA/U87_re/se
# sh /cluster/home/futing/pipeline/RNA/rna_pe.sh /cluster/home/futing/Project/GBM/RNA/U87_re/pe

FASTQ_DIR=/cluster/home/futing/Project/GBM/RNA/U87_re/se
cd /cluster/home/futing/Project/GBM/RNA/U87_re/se
cat filename.txt | while read i;do
    echo "Running RSEM..."
    rsem-calculate-expression -no-bam-output --alignments -p 20 \
        ${FASTQ_DIR}/aligned/${i}Aligned.toTranscriptome.out.bam \
        /cluster/home/futing/ref_genome/hg38_gencode/RSEM/RSEM \
        ${FASTQ_DIR}/rsem_out/${i}
done