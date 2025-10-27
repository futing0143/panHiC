#!/bin/bash

source /cluster/home/chenglong/.bashrc
source activate /cluster/home/chenglong/miniconda3/envs/tag2rose
input=/cluster2/home/futing/Project/panCancer/Analysis/dchic/MCF10A/SRP229605_SRS5640068_GSM4158369_MCF10A_WT_input_CTCF_1_BRCA_hg38.bam
H3K27ac=/cluster2/home/futing/Project/panCancer/Analysis/dchic/MCF10A/SRP293301_SRS7741395_GSM4915940put_H3K27ac_MCF10a_serum_BRCA_hg38.bam

cd /cluster2/home/futing/Project/panCancer/Analysis/dchic/MCF10A
bamCoverage -b $input -o MCF10A_WT_input_CTCF_1_BRCA.bw --normalizeUsing RPKM --binSize 10 --smoothLength 30 --extendReads 200
bamCoverage -b $H3K27ac -o MCF10A_H3K27ac_serum_BRCA.bw --normalizeUsing RPKM --binSize 10 --smoothLength 30 --extendReads 200
macs2 callpeak -t $H3K27ac -c $input -f BAM -g hs -n MCF10A_H3K27ac_serum_BRCA --outdir ./bwa --keep-dup all -q 0.05
