#!/bin/bash

wkdir=/cluster2/home/futing/Project/panCancer/MB
cd $wkdir

IFS=$','
while read -r gse cell enzyme other;do
	echo -e "$gse $cell $enzyme and $other"
	sh $wkdir/sbatch.sh $gse $cell $enzyme
	
done < <(head -n 7 "/cluster2/home/futing/Project/panCancer/MB/meta/MBmeta_July02.txt")


sh $wkdir/sbatch.sh GSE240410 MB234 MboI "-S dedup"


for i in MB174 MB199 MB227 MB268 MB277 MB288;do

	sh /cluster2/home/futing/Project/panCancer/MB/sbatch.sh \
		GSE240410 ${i} MboI
done