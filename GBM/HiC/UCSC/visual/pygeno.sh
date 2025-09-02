#!/bin/bash
cd /cluster/home/futing/Project/GBM/HiC/UCSC/A172
comp=/cluster/home/futing/Project/GBM/HiC/UCSC/A172/A172_compartment_100k.bedGraph
hicfile=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/A172/aligned/inter_30.hic
coolfile=/cluster/home/futing/Project/GBM/HiC/02data/03cool_order/10000/A172_10000.cool
loop=/cluster/home/futing/Project/GBM/HiC/UCSC/A172/loop/A172_concen.bedpe
genegtf=/cluster/home/futing/ref_genome/hg38_gencode/genebed/gencode.v43.annotation.gtf
TADfile=/cluster/home/futing/Project/GBM/HiC/08TAD/OnTAD/10000/A172/A172_2.bed


cp $loop /cluster/home/futing/Project/GBM/HiC/UCSC/A172/loop/A172_concen.links
hicConvertFormat -m $coolfile --inputFormat cool --outputFormat h5 \
    -o /cluster/home/futing/Project/GBM/HiC/UCSC/A172/A172.h5

awk 'BEGIN{FS=OFS="\t"}
    NR==1{print1}
    NR>1{print "chr"$1,$2,$3,$4,$5,$6,$7,$8,$9}' $TADfile \
    > /cluster/home/futing/Project/GBM/HiC/UCSC/A172/TAD/A172_TAD.domains

make_tracks_file --trackFiles /cluster/home/futing/Project/GBM/HiC/UCSC/A172/A172.h5 \
    /cluster/home/futing/Project/GBM/HiC/UCSC/A172/TAD/A172_TAD.domains \
    /cluster/home/futing/Project/GBM/HiC/UCSC/A172/loop/A172_concen.links $genegtf \
    -o /cluster/home/futing/Project/GBM/HiC/UCSC/A172/tracks.ini

pyGenomeTracks \
    --tracks /cluster/home/futing/Project/GBM/HiC/UCSC/A172/tracks.ini \
    --region chr2:10,000,000-11,000,000 \
    --outFileName /cluster/home/futing/Project/GBM/HiC/UCSC/A172/output2.pdf


