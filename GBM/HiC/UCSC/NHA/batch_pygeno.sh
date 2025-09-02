#!/bin/bash

cd /cluster/home/futing/Project/GBM/HiC/UCSC/NHA
NHAdir=/cluster/home/futing/Project/GBM/HiC/UCSC/NHA
vlinebed=/cluster/home/futing/Project/GBM/HiC/UCSC/NHA/vlines.bed

IFS=$'\t'
while read -r HAR chr start end;do
	echo -e "Processing ${HAR} at ${chr}, ${start} and ${end}..."
	IFS='_' read -r chr1 start1 end1 <<< "${HAR}"
	echo -e "${chr}\t${start}\t${start1}" > ${vlinebed}
	echo -e "${chr1}\t${start1}\t${end1}" >> ${vlinebed}
	echo -e "${chr1}\t${end1}\t${end}" >> ${vlinebed}
	
	pyGenomeTracks \
		--tracks ${NHAdir}/tracks.ini \
		--region ${chr}:${start}-${end} \
		--outFileName ${NHAdir}/RNAbygene/${HAR}.pdf
	if [ $? -eq 0 ];then
		continue
		# echo -e "Done with ${HAR} at ${chr}, ${start} and ${end}..."
	else
		echo -e "${HAR}\t${chr}\t${start}\t${end}" >> HARs_failed.txt
	fi
done < "${NHAdir}/HARregion_GBMvsNHA_RNAbygene.txt"

