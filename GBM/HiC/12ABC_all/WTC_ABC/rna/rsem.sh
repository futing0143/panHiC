#!/bin/bash
rsem_index='/cluster/home/futing/ref_genome/hg38_gencode/RSEM/RSEM'

source activate ~/anaconda3/envs/RNAseq
cd /cluster/home/futing/Project/GBM/RNA/iPSC
find /cluster/home/futing/Project/GBM/RNA/iPSC/star_out -name '*_Aligned.toTranscriptome.out.bam' | while read -r file; do
    i=$(basename "$file" _Aligned.toTranscriptome.out.bam)
    echo "Processing $i..."
    rsem-calculate-expression \
        --no-bam-output -p 10 \
        --alignments --paired-end \
        ./star_out/${i}_Aligned.toTranscriptome.out.bam \
        ${rsem_index} ./rsem_out/${i}
done

sh /cluster/home/futing/Project/GBM/RNA/iPSC/mergeTPM.sh