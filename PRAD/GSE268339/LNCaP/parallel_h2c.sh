#!/bin/bash

# find /cluster2/home/futing/Project/panCancer/PRAD/GSE268339/LNCaP     -name '*.hic' | while read -r file;do
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



while read -r dir;do
	echo "Processing $dir"
	cd /cluster2/home/futing/Project/panCancer/PRAD/GSE268339/
	cell=$(basename ${dir} | cut -d'_' -f2)
	# mkdir -p ./${cell}/{aligned,cool,anno,fastq}
	# mv GSM*${cell}*.hic ./${cell}/aligned/inter_30.hic
	# mv ./${cell}/aligned/*.hic ./${cell}/aligned/inter_30.hic

	sh /cluster2/home/futing/Project/panCancer/PRAD/sbatch.sh \
		GSE268339 ${cell} unknown

done < "/cluster2/home/futing/Project/panCancer/PRAD/GSE268339/LNCaP/dir.txt"