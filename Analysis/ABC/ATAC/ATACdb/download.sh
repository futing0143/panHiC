#!/bin/bash


# wget -c https://bio.liclab.net/ATACdb_static/download/Accessible_chromatin_region/bed/Sample_H_3416.bed
cd /cluster2/home/futing/public_data/ATACdb
IFS=$'\t'
while read -r cancer cell id;do
	# mkdir -p ${cancer}/${cell}
	echo "Downloading ${cancer}/${cell}/${id}.bed.gz"
	echo "wget -c -O ${cancer}/${cell}/${id}.bed.gz https://bio.liclab.net/ATACdb_static/download/Accessible_chromatin_region/bed/${id}.bed"
	wget -c -O ${cancer}/${cell}/${id}.bed.gz https://bio.liclab.net/ATACdb_static/download/Accessible_chromatin_region/bed/${id}.bed
done < <(cut -f1,2,4 /cluster2/home/futing/public_data/ATACdb/ATAC_notna_fuzzy_merged.tsv)

# cut -f1,2 /cluster2/home/futing/public_data/ATACdb/ATAC_notna_fuzzy_merged.tsv \
# 	| sort -k1 -k2 -u > /cluster2/home/futing/public_data/ATACdb/panCan_ATACdb.txt