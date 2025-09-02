#!/bin/bash

d=$1
check_file() {
    local file="$1"
    if [ -e "$file" ] && [ -s "$file" ]; then
        return 0    # 存在且非空
    else
        return 1    # 不存在或为空
    fi
}

unalign=/cluster2/home/futing/Project/panCancer/check/aligned/unalign${d}.txt
unrun_file=/cluster2/home/futing/Project/panCancer/check/aligned/unrun${d}.txt
aligndone=/cluster2/home/futing/Project/panCancer/check/aligned/aligndone${d}.txt
filelist=/cluster2/home/futing/Project/panCancer/check/panCan_meta.txt
>${unalign}
>${unrun_file}
>${aligndone}
# IFS=$','
# while read -r gse cell other;do
# 	hic_exist=false
# 	f="/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}/aligned/inter_30.hic"
# 	[ -e "$f" ] && check_file "$f" && hic_exist=true
# 	if ! $hic_exist;then
# 		echo -e "${gse}\t${cell}" >> $unalign
# 	fi
# done < "$filelist"


IFS=$'\t'
while read -r cancer gse cell other; do
    splitdir="/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}/splits"
    if [ ! -d "$splitdir" ]; then
        echo -e "${cancer}\t${gse}\t${cell}" >> "$unrun_file"
    else
		zcat -f "${splitdir}"/*_linecount.txt* "${splitdir}"/*norm*res*.txt* | \
		awk -v cancer="$cancer" -v gse="$gse" -v cell="$cell" \
			-v unalign="$unalign" \
			-v done_file="$aligndone" '
			BEGIN {total=0; check=0}
			FILENAME ~ /_linecount.txt/ {total += $1/4; next}
			FILENAME ~ /norm.*res/ {check += $2; next}
			END {
				if (total != check) {
					print cancer "\t" gse "\t" cell >> unalign
				} else {
					print cancer "\t" gse "\t" cell >> done_file
				}
			}
		'
    fi
done < "$filelist"



# # 找到正确
i=SRR13478584
splitdir=/cluster2/home/futing/Project/panCancer/AML/GSE165038/U937/splits
wctotal=`cat ${splitdir}/${i}.fastq.gz_linecount.txt | awk '{sum+=$1}END{print sum/4}'`
check2=`cat ${splitdir}/${i}.fastq.gz_norm.txt.res.txt | awk '{s2+=$2;}END{print s2}'`
echo $wctotal
echo $check2