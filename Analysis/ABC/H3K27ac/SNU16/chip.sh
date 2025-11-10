#!/bin/bash

source /cluster/home/chenglong/.bashrc
source activate /cluster/home/chenglong/miniconda3/envs/tag2rose
input=/cluster2/home/futing/Project/panCancer/Analysis/dchic/SNU16/GSE159986_GSM4851925_SNU16_input_hg38.bam
H3K27ac=/cluster2/home/futing/Project/panCancer/Analysis/dchic/SNU16/GSE159986_GSM4851921_SNU16_H3K27ac_rep1_hg38.bam
H3K27ac2=/cluster2/home/futing/Project/panCancer/Analysis/dchic/SNU16/GSE159986_GSM4851922_SNU16_H3K27ac_rep2_hg38.bam

cd /cluster2/home/futing/Project/panCancer/Analysis/dchic/SNU16
bamCoverage -b $input -o SNU16_input.bw --normalizeUsing RPKM --binSize 10 --smoothLength 30 --extendReads 200
bamCoverage -b $H3K27ac -o SNU16_H3K27ac_rep1.bw --normalizeUsing RPKM --binSize 10 --smoothLength 30 --extendReads 200
bamCoverage -b $H3K27ac2 -o SNU16_H3K27ac_rep2.bw --normalizeUsing RPKM --binSize 10 --smoothLength 30 --extendReads 200

macs2 callpeak -t $H3K27ac -c $input -f BAM -g hs -n SNU16_H3K27ac_rep1 --outdir ./macs2 -q 0.05
macs2 callpeak -t $H3K27ac2 -c $input -f BAM -g hs -n SNU16_H3K27ac_rep2 --outdir ./macs2 -q 0.05
