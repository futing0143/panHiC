#!/bin/bash
cd /cluster/home/futing/Project/GBM/ChIP/CTCF/NPC/macs2

awk 'BEGIN{OFS="\t"} {print $1, $2, $3, $7}' /cluster/home/futing/Project/GBM/ChIP/CTCF/NPC/macs2/SRR22528422_peaks.narrowPeak > output.bedGraph
# bedgragh 2 bigwig
LC_ALL=C sort -k1,1 -k2,2n output.bedGraph > sorted_output.bedGraph
bedGraphToBigWig sorted_output.bedGraph /cluster/home/futing/ref_genome/hg38.chrom.sizes NPC.bw
