#!/bin/bash
cd /cluster2/home/futing/Project/panCancer/CRC/GSE182105

# find /cluster2/home/futing/Project/panCancer/CRC/GSE207951 -name '*.hic' | while read -r file;do
# 	echo "Proessing file: $file"
# 	name=$(basename ${file} .hg38.nodups.pairs.hic | cut -d'_' -f2)
# 	if [[ -d "./${name}" ]];then
# 		echo "${name} directory already exists, skipping creation."
# 		mkdir -p "./${name}/"{aligned,cool,anno,fastq}
# 		# mv ${file} ./${name}/aligned/inter_30.hic
# 		# sh /cluster2/home/futing/Project/panCancer/CRC/sbatch.sh \
# 		# 	GSE207951 ${name} mHiC
# 	else
# 		echo "Creating directory ${name} ..."
# 		mkdir -p "./${name}/"{aligned,cool,anno,fastq}
# 		# mv ${file} ./${name}/aligned/inter_30.hic
# 	fi
# done



while read -r cell;do
	echo "Processing cell: $cell"
	cd /cluster2/home/futing/Project/panCancer/CRC/GSE207951

	mkdir -p ./${cell}/{aligned,cool,anno,fastq}
	# mv GSM*${cell}* ./${cell}/aligned/
	mv ./${cell}/aligned/*.hic ./${cell}/aligned/inter_30.hic

	sh /cluster2/home/futing/Project/panCancer/CRC/sbatch.sh \
		GSE207951 ${cell} mHIC

done < "/cluster2/home/futing/Project/panCancer/CRC/GSE207951/dir.txt"