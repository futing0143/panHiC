#!/bin/bash
cd /cluster2/home/futing/Project/panCancer/CRC/GSE160235/DLD-1
gse=GSE160235
cell=DLD-1
for i in SRR12914630 SRR12914631 SRR12914634 SRR12914637;do

    splitdir="/cluster2/home/futing/Project/panCancer/CRC/${gse}/${cell}/splits"
	wctotal=`cat ${splitdir}/${i}.fastq.gz_linecount.txt | awk '{sum+=$1}END{print sum/4}'`
	check2=`cat ${splitdir}/${i}.fastq.gz_norm.txt.res.txt | awk '{s2+=$2;}END{print s2}'`
	echo -e "$wctotal\t$check2" >> check.txt
done