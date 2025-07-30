#!/bin/bash


cd /cluster2/home/futing/Project/panCancer/PRAD/

# check debug 
grep -rl 'err' ./debug/*.log | cut -f3 -d '/' | cut -f1 -d '_' | sort -u > ./dumperr.txt
find . -name '*_2.fastq.gz' -exec basename {} _2.fastq.gz \; | sort -u > done.txt
find . -regex '.*/SRR[0-9]+$' -exec basename {} \; | cut -f1 -d '_' | sort -u > done.txt
grep -F -v -w -f done.txt <(cut -f2 PRAD.txt) > undone.txt

grep -w -F -v -f dumperr.txt done.txt > done0716.txt
grep -w -F -v -f done.txt srr.txt > undone.txt

# sbatch done
sort -k2 tmp.txt > sorted && mv sorted tmp.txt
join -1 2 -2 1 tmp.txt done.txt > PRAD_done.txt


# mv files
IFS=$' '
while read -r gse srr cell other;do
	echo -e "mv ./${srr}*.fastq.gz ./$gse/$cell"
	mkdir -p /cluster2/home/futing/Project/panCancer/PRAD/$gse/$cell
	mv ./${srr}*.fastq.gz ./$gse/$cell
done < 'PRAD_done.txt'