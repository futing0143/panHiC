#!/bin/bash


for i in NPC U87_new TS543 TS576 U251 U343; do
  find /cluster/home/futing/Project/GBM/ChIP/H3K27ac/${i} -name "*.bam" | sed "s|^|${i}\t|" >> bam_reads.txt
done

IFS=$'\t'
while read -r sample dir input;do
	id=$(basename $dir .rmdup_sorted.bam)
	echo -e "${sample}\t${dir}\t${input}\t${id}" >> tmp

done < 'bam_reads.txt'




for i in NPC U87_new TS543 TS576 U251 U343 ;do
	find /cluster/home/futing/Project/GBM/ChIP/H3K27ac/${i} -name "*.narrowPeak" | sed "s|^|${i}\t|" >> bed_reads.txt
done
 
find /cluster/home/futing/Project/GBM/ChIP/H3K27ac/GSC -name "*.bed" | while read line;do
	id=$(basename $line | cut -d "_" -f 2)
	echo -e "${id}\t${line}" >> bed_reads.txt
done

IFS=$'\t'
while read -r sample dir;do
	if [[ $sample == G* ]];then
		echo -e "${sample}\t${dir}\t${sample}" >> tmp
	else
		echo "$sample is not GSC"
		id=$(basename $dir _peaks.narrowPeak)
		echo -e "${sample}\t${dir}\t${id}" >> tmp
	fi
done < 'bed_reads.txt'
