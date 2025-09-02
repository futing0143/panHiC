#!/bin/bash

mkdir -p /cluster/home/futing/Project/GBM/HiC/UCSC/NPC/HARs_RNA
cd /cluster/home/futing/Project/GBM/HiC/UCSC/NPC
# tail -n +2 /cluster/home/futing/Project/GBM/HiC/HAR/HARs_gene/genes/HARregion_GBM.txt > HARregion.txt

IFS=$'\t'
while read -r HAR chr start end;do
	echo -e "Processing ${HAR} at ${chr}, ${start} and ${end}..."
	pyGenomeTracks \
		--tracks /cluster/home/futing/Project/GBM/HiC/UCSC/NPC/tracks.ini \
		--region ${chr}:${start}-${end} \
		--outFileName /cluster/home/futing/Project/GBM/HiC/UCSC/NPC/HARs_fil/${HAR}.pdf
	if [ $? -eq 0 ];then
		continue
		# echo -e "Done with ${HAR} at ${chr}, ${start} and ${end}..."
	else
		echo -e "${HAR}\t${chr}\t${start}\t${end}" >> HARs_failed.txt
	fi
done < '../GBM/RNA.txt'


cat /cluster/home/futing/Project/GBM/HiC/UCSC/GBM/HARregionH3K27ac.txt | while read line;do
	HAR=$(echo $line | awk '{print $1}')
	# echo -e "Processing ${HAR}..."
	mv /cluster/home/futing/Project/GBM/HiC/UCSC/NPC/HARs_fil/${HAR}.pdf \
		/cluster/home/futing/Project/GBM/HiC/UCSC/NPC/HARs_H3K27ac/${HAR}.pdf
done