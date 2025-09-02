#!/bin/bash

# 给 HARregion 绘制每个HARs的热图

mkdir -p /cluster/home/futing/Project/GBM/HiC/UCSC/GBM/HARs_RNA
cd /cluster/home/futing/Project/GBM/HiC/UCSC/GBM
# tail -n +2 /cluster/home/futing/Project/GBM/HiC/HAR/HARs_gene/genes/HARregion_GBM.txt > HARregion.txt
# tail -n +2 /cluster/home/futing/Project/GBM/HiC/HAR/HARs_gene/genes/GBMup/HARregion_GBM.txt > HARregionH3K27ac.txt

HARslist=RNA.txt
tail -n +2 /cluster/home/futing/Project/GBM/HiC/HAR/HARs_gene/genes/all/HARregion_GBM_RNA.txt \
	> HARregionRNA.txt

IFS=$'\t'
while read -r HAR chr start end;do
	echo -e "Processing ${HAR} at ${chr}, ${start} and ${end}..."
	pyGenomeTracks \
		--tracks /cluster/home/futing/Project/GBM/HiC/UCSC/GBM/tracks.ini \
		--region ${chr}:${start}-${end} \
		--outFileName /cluster/home/futing/Project/GBM/HiC/UCSC/GBM/HARs_fil/${HAR}_new.pdf
	if [ $? -eq 0 ];then
		continue
		# echo -e "Done with ${HAR} at ${chr}, ${start} and ${end}..."
	else
		echo -e "${HAR}\t${chr}\t${start}\t${end}" >> HARs_failed.txt
	fi
done < ${HARslist}

# cat useful.txt | while read HAR;do
# 	mv ./HARs/${HAR}.pdf ./useful/
# done

