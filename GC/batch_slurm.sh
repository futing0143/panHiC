#!/bin/bash

wkdir=/cluster2/home/futing/Project/panCancer/GC
cd $wkdir

IFS=$','
while read -r gse cell enzyme other;do
	echo -e "$gse $cell $enzyme and $other"
	sh $wkdir/sbatch.sh $gse $cell $enzyme
	
done < '/cluster2/home/futing/Project/panCancer/GC/GC_meta2.txt'


# IFS=$','
# while read -r gse srr cell other;do
# 	echo -e "$gse $cell $srr and $other"
# 	mkdir -p ${gse}/${cell}
# 	mv ${srr}/* ${gse}/${cell}
	
# done < '/cluster2/home/futing/Project/panCancer/GC/GC_metadoneJun292.txt'