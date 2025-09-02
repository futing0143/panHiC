#!/bin/bash

name='NPC'
cd /cluster/home/futing/Project/GBM/HiC/UCSC/${name}

# for test
genegtf=/cluster/home/futing/ref_genome/hg38_gencode/genebed/gencode.v43.annotation.gtf

file=chr10_24728545_24728698
coolfile=/cluster/home/futing/Project/GBM/HiC/02data/03cool_order/10000/{name}_10000.cool
RNA='/cluster/home/futing/Project/GBM/RNA/sample/GSC/GSM7182056_G61_S_q20.bw'
H3K27ac='/cluster/home/futing/Project/GBM/HiC/hubgene/new/H3K27ac/merge/${name}.merge_BS_detail.bw'
loop_file=/cluster/home/futing/Project/GBM/HiC/10loop/consensus/merged/flank0k/${name}_flank0k.bedpe


cp $loop_file /cluster/home/futing/Project/GBM/HiC/UCSC/${name}/${name}.links


# hicConvertFormat -m $coolfile --inputFormat cool --outputFormat h5 \
#     -o /cluster/home/futing/Project/GBM/HiC/UCSC/GBM/GBM.h5

# awk 'BEGIN{FS=OFS="\t"}
#     NR==1{print1}
#     NR>1{print "chr"$1,$2,$3,$4,$5,$6,$7,$8,$9}' $TADfile \
#     > /cluster/home/futing/Project/GBM/HiC/UCSC/A172/TAD/A172_TAD.domains

make_tracks_file --trackFiles /cluster/home/futing/Project/GBM/HiC/UCSC/GBM/GBM.h5 \
	$H3K27ac $RNA \
    /cluster/home/futing/Project/GBM/HiC/UCSC/GBM/GBM.links $genegtf \
    -o /cluster/home/futing/Project/GBM/HiC/UCSC/GBM/tracks.ini

pyGenomeTracks \
    --tracks /cluster/home/futing/Project/GBM/HiC/UCSC/GBM/tracks_GBM.ini \
    --region chr10:117532444-118054037 \
    --outFileName /cluster/home/futing/Project/GBM/HiC/UCSC/GBM/GBM1.pdf


