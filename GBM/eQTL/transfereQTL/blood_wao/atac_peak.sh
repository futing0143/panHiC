#!/bin/bash
cat /cluster/home/jialu/GBM/HiC/WTC_ABC/atac/atac_rep1_peaks.narrowPeak.sorted /cluster/home/jialu/GBM/HiC/WTC_ABC/atac/atac_rep2_peaks.narrowPeak.sorted > WTC.atac.merge.narrowPeak
bedtools sort -faidx /cluster/share/ref_genome/hg38/assembly/hg38.chrom.sizes -i WTC.atac.merge.narrowPeak > WTC.atac.merge.narrowPeak.sorted
bedtools merge -i WTC.atac.merge.narrowPeak.sorted > WTC.atac.merge.narrowPeak.sorted.merged