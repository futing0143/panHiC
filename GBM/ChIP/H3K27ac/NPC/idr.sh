#!/bin/bash
cd /cluster/home/futing/Project/GBM/ChIP/H3K27ac/NPC/macs2
name=NPC
awk 'BEGIN{OFS="\t"} {print $1, $2, $3, $7}' ./SRR22528424_peaks.narrowPeak > output.bedGraph
# bedgragh 2 bigwigno
LC_ALL=C sort -k1,1 -k2,2n output.bedGraph > sorted_output.bedGraph
bedGraphToBigWig sorted_output.bedGraph /cluster/home/futing/ref_genome/hg38.chrom.sizes ${name}_H3K27ac.bw
