#!/bin/bash



mv /cluster2/home/WeiNa/ft/SRR9030110/* /cluster2/home/futing/Project/panCancer/BRCA
find /cluster2/home/WeiNa/ft/ -name '*.fastq.gz' -exec mv {} /cluster2/home/futing/Project/panCancer/BRCA \;


IFS=$','
while read -r gse gsm srr cell other;do
	echo -e "mv ./${srr}* ${gse}/${cell}/"
	mkdir -p ${gse}/${cell}
	mv ./${srr}* ${gse}/${cell}/
done < <(tail -n +2 /cluster2/home/futing/Project/panCancer/BRCA/04BRCA_2nana.csv)

tail -n +2 /cluster2/home/futing/Project/panCancer/BRCA/04BRCA_2nana.csv \
	| cut -d ',' -f 1,3,4 | sort -u > BRCA.txt
tail -n +2 /cluster2/home/futing/Project/panCancer/BRCA/04BRCA_2nana.csv \
	| cut -d ',' -f 1,4 | sort -u > BRCA_meta.txt

grep 'GSE167150' /cluster2/home/futing/Project/panCancer/BRCA/meta/BRCA_meta.txt | while read -r gse cell enzyme;do
	echo "Processing GSE: $gse, Cell: $cell, Enzyme: $enzyme"
	sh /cluster2/home/futing/Project/panCancer/BRCA/sbatch.sh "$gse" "$cell" "$enzyme"
done