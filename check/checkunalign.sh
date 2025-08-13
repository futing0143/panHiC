#!/bin/bash


check_file() {
    local file="$1"
    if [ -e "$file" ] && [ -s "$file" ]; then
        return 0    # 存在且非空
    else
        return 1    # 不存在或为空
    fi
}

output_file=/cluster2/home/futing/Project/panCancer/check/align0812.txt
unrun_file=/cluster2/home/futing/Project/panCancer/check/unrun0812.txt
filelist=/cluster2/home/futing/Project/panCancer/check/panCan_meta.txt
# >${output_file}
# >${unrun_file}
# IFS=$','
# while read -r gse cell other;do
# 	hic_exist=false
# 	f="/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}/aligned/inter_30.hic"
# 	[ -e "$f" ] && check_file "$f" && hic_exist=true
# 	if ! $hic_exist;then
# 		echo -e "${gse}\t${cell}" >> $output_file
# 	fi
# done < "$filelist"


IFS=$'\t'
while read -r cancer gse cell other; do
    splitdir="/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}/splits"
	if [ ! -d "$splitdir" ]; then
		echo -e "${cancer}\t${gse}\t${cell}" >> "$unrun_file"
	else
		awk 'BEGIN {total=0; check=0}
			FILENAME ~ /_linecount.txt$/ {total += $1/4; next}
			FILENAME ~ /norm.*res/ {check += $2; next}
			END {if (total != check) print "'"$cancer"'\t'"$gse"'\t'"$cell"'" >> "'"$output_file"'"}
		' ${splitdir}/*_linecount.txt ${splitdir}/*norm*res*
	fi
done < "$filelist"


# # 找到正确
# i=SRR13478584
# splitdir=/cluster2/home/futing/Project/panCancer/AML/GSE165038/U937/splits
# wctotal=`cat ${splitdir}/${i}.fastq.gz_linecount.txt | awk '{sum+=$1}END{print sum/4}'`
# check2=`cat ${splitdir}/${i}.fastq.gz_norm.txt.res.txt | awk '{s2+=$2;}END{print s2}'`
# echo $wctotal
# echo $check2