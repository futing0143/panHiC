#!/bin/bash
#conda activate atacseq
filepath='/cluster/home/jialu/GBM/HiC/ABC/atac'
indexpath="/cluster/share/ref_genome/GRCh38.p13/index/bowtie2/GRCh38.p13.fa"


mkdir -p ${filepath}/{qc,align}

cat fiename.txt | while read i
do
#quality control
trim_galore --phred33 -q 20 --length 20 --stringency 3 -e 0.1 --fastqc --paired -o ${filepath}/qc ${i}.R1.fastq.gz ${i}.R2.fastq.gz
fastqc ${filepath}/*.gz &

#mapping
bowtie2 -p 20 -x ${indexpath} -X 1000 -1 ${i}.R1.fastq.gz -2 ${i}.R2.fastq.gz | samtools view -F 4 -bS - > ${filepath}/align/${i}.bam 

#qc after mapping
samtools view -f 2 -q 30 -o ${filepath}/align/${i}.q30.bam ${filepath}/align/${i}.bam
samtools sort -@ 20 -o ${filepath}/align/${i}.q30.sort.bam ${filepath}/align/${i}.q30.bam
samtools flagstat ${filepath}/align/${i}.q30.sort.bam > ${filepath}/align/${i}.q30.sort.stat

gatk MarkDuplicates VERBOSITY=ERROR QUIET=true CREATE_INDEX=false REMOVE_DUPLICATES=true I=${filepath}/align/${i}.q30.sort.bam O=${filepath}/align/${i}.f2.q30.sort.rmdup.bam M=${filepath}/align/${i}.marked_dup.log
samtools view -h ${filepath}/align/${i}.f2.q30.sort.rmdup.bam | grep "Mt" -v | grep "Pt" -v | samtools view -bS -o ${filepath}/align/${i}.final.bam
done
