#!/bin/bash
input=$1
HARslist=/cluster/home/futing/Project/GBM/HiC/HAR/HARs_gene/genes/HARregion/HARregion_GBMdiff.txt
vlinebed=/cluster/home/futing/Project/GBM/HiC/UCSC/GBM/vlines.bed
IFS=$'\t'
while read -r HAR chr start end;do
	if [[ ${HAR} == ${input} ]];then
		echo -e "Processing ${HAR} at ${chr}, ${start} and ${end}..."
		IFS='_' read -r chr1 start1 end1 <<< "${HAR}"

		echo -e "${chr}\t${start}\t${start1}" > ${vlinebed}
		echo -e "${chr1}\t${start1}\t${end1}" >> ${vlinebed}
		echo -e "${chr1}\t${end1}\t${end}" >> ${vlinebed}
		# pyGenomeTracks \
		# 	--tracks /cluster/home/futing/Project/GBM/HiC/UCSC/GBM/tracks.ini \
		# 	--region ${chr}:${start}-${end} \
		# 	--outFileName /cluster/home/futing/Project/GBM/HiC/UCSC/GBM/HARs_RNA/new/${HAR}_new.pdf
		pyGenomeTracks \
			--tracks /cluster/home/futing/Project/GBM/HiC/UCSC/NPC/tracks.ini \
			--region ${chr}:${start}-${end} \
			--outFileName /cluster/home/futing/Project/GBM/HiC/UCSC/NPC/HARs_RNA/${HAR}_nodiag_new.pdf
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

