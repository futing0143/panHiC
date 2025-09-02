#!/bin/bash
mkdir /cluster/home/futing/Project/GBM/HiC/08TAD/OnTAD/G1
cd /cluster/home/futing/Project/GBM/HiC/08TAD/OnTAD/G1
while IFS=$'\t' read -r chr length;do
    echo "chr: ${chr}, length: ${length}"
    /cluster/home/futing/software/OnTAD-master/src/OnTAD \
        /cluster/home/futing/Project/GBM/HiC/02data/02hic/GBM/G1.hic \
        -bedout ${chr} ${length} 10000 \
        -o G1_${chr}
    awk 'NR>1{print $0}' G1_*.bed > G1.bed

done < "/cluster/home/futing/ref_genome/hg38.genome"