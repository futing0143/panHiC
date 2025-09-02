#!/bin/bash
rsem_index='/cluster/home/futing/ref_genome/hg38_gencode/RSEM/RSEM'

source activate RNA
cd /cluster/home/futing/Project/GBM/RNA/sample/NPC
mkdir -p rsem_out_$(date +%Y%m%d)
find ./star_out -name '*_Aligned.toTranscriptome.out.bam' | while read -r file; do
    i=$(basename "$file" _Aligned.toTranscriptome.out.bam)
    echo "Processing $i..."
    rsem-calculate-expression \
        --no-bam-output -p 10 \
        --alignments --paired-end \
        ./star_out/${i}_Aligned.toTranscriptome.out.bam \
        ${rsem_index} ./rsem_out_$(date +%Y%m%d)/${i}
done

# sh /cluster/home/futing/Project/GBM/RNA/NPC/mergeTPM.sh