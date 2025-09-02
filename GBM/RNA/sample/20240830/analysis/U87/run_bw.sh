#!/bin/bash
cd /cluster/home/futing/Project/GBM/RNA/sample/20240830/analysis/U87
source activate scRNAseq

# samtools index U87.bam

# bamCoverage -b U87.bam -o U87.bw #--scaleFactor 1 --minMappingQuality 20

bamCoverage -b U87.bam -o "U87_RPKM.bw" --normalizeUsing RPKM

# bedGraphToBigWig ./macs2/sorted_output.bedGraph \
	# /cluster/home/futing/ref_genome/hg38.chrom.sizes ./macs2/U87_H3K27ac.bw


