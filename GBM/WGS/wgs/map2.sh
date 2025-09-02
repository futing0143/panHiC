#!/bin/bash
#remember to change your exon.bed file


## conda env
source /cluster/home/hjwu/soft/miniconda3_20211020/etc/profile.d/conda.sh
conda deactivate
conda activate day

## input
sample=$1
bname=`basename $sample`

## pars
nCPU=16
bwa_index=/cluster/home/haojie/hg38/Homo_sapiens_assembly38.fasta
fastq=`ls -d ${sample}* |xargs`
bam=$bname/bwa/$bname.bam
bam_unsorted=$bname/bwa/$bname.presort.bam
tmp=$bname/bwa/$bname
seqdep=$bname/bwa/${bname}.mosdepth/${bname}

## make dir for bwa
if [ ! -d $bname/bwa ]
then
    mkdir -p $bname/bwa
fi

## make dir for bwa sequence depth
if [ ! -d $bname/bwa/${bname}.mosdepth ]
then
    mkdir -p $bname/bwa/${bname}.mosdepth
fi

## run mapping
if [ ! -e $bam ] && [ ! -e $bam_unsorted ]
then
    bwa mem -M -t $nCPU $bwa_index $fastq | \
        samtools view -Shb - > $bam_unsorted
fi

## run sorting
if [ ! -e $bam ]
then
    samtools fixmate --threads $nCPU -m $bam_unsorted - \
        |samtools sort --threads $nCPU -T $tmp - \
        |samtools markdup --threads $nCPU -T $tmp -S -s - $bam
fi

## run indexing
if [ ! -e $bam.bai ]
then
    samtools index $bam
fi

## run stat
if [ ! -e $bam.stat ]
then
    samtools flagstat $bam > $bam.stat
fi

rm $seqdep.mosdepth.summary.txt
###21/12/13 add

## run sequence depth calculation
# exon=/cluster/home/hjwu/genome/hg38/annotation/gencode.v38.exon.bed
# exon=/cluster/share/ref_genome/hg38/annotation/gencode.v38.exon.bed
#exon=/cluster/home/haojie/data/mi/exon.shihe.bed
#exon=/cluster/home/jialu/wesdata/S07604514_Covered_col123.bed
#exon=/cluster/home/jialu/wes_data_0705/WES/LCOC/hg38_RefSeq_col3.bed
if [ ! -e $seqdep.mosdepth.summary.txt ]
then
    conda deactivate
    conda activate mosdepth_0.3.2
    mosdepth -n -b $seqdep $bam
    conda deactivate
    conda activate day
fi

## remove tmp file
rm $bam_unsorted


