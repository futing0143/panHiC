#!/bin/bash
input=$1
HARslist=/cluster/home/futing/Project/GBM/HiC/UCSC/NHA/HARregion_GBMvsNHA_bygene.txt
# HARslist=/cluster/home/futing/Project/GBM/HiC/UCSC/NHA/specific.txt
vlinebed=/cluster/home/futing/Project/GBM/HiC/UCSC/GBM/vlines.bed
NHAdir=/cluster/home/futing/Project/GBM/HiC/UCSC/NHA
GBMdir=/cluster/home/futing/Project/GBM/HiC/UCSC/GBM

IFS=$'\t'
while read -r HAR chr start end;do
	if [[ ${HAR} == ${input} ]];then
		echo -e "Processing ${HAR} at ${chr}, ${start} and ${end}..."
		IFS='_' read -r chr1 start1 end1 <<< "${HAR}"

		echo -e "${chr}\t${start}\t${start1}" > ${vlinebed}
		echo -e "${chr1}\t${start1}\t${end1}" >> ${vlinebed}
		echo -e "${chr1}\t${end1}\t${end}" >> ${vlinebed}
		pyGenomeTracks \
			--tracks ${GBMdir}/tracks.ini \
			--region ${chr}:${start}-${end} \
			--outFileName ${GBMdir}/HARs_RNA/pathway/${HAR}.pdf
		pyGenomeTracks \
			--tracks ${NHAdir}/tracks.ini \
			--region ${chr}:${start}-${end} \
			--outFileName ${NHAdir}/pathway/${HAR}.pdf
	else
		continue
	fi

	if [ $? -eq 0 ];then
		continue
		# echo -e "Done with ${HAR} at ${chr}, ${start} and ${end}..."
	else
		echo -e "${HAR}\t${chr}\t${start}\t${end}" >> HARs_failed.txt
	fi
done < ${HARslist}

