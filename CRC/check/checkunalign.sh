#!/bin/bash


check_file() {
    local file="$1"
    if [ -e "$file" ] && [ -s "$file" ]; then
        return 0    # 存在且非空
    else
        return 1    # 不存在或为空
    fi
}

output_file=/cluster2/home/futing/Project/panCancer/CRC/check/CRC_align0804.txt
filelist=/cluster2/home/futing/Project/panCancer/CRC/meta/CRC_meta.txt
>${output_file}
# IFS=$','
# while read -r gse cell other;do
# 	hic_exist=false
# 	f="/cluster2/home/futing/Project/panCancer/CRC/${gse}/${cell}/aligned/inter_30.hic"
# 	[ -e "$f" ] && check_file "$f" && hic_exist=true
# 	if ! $hic_exist;then
# 		echo -e "${gse}\t${cell}" >> $output_file
# 	fi
# done < "$filelist"


IFS=$','
while read -r gse cell other; do
    splitdir="/cluster2/home/futing/Project/panCancer/CRC/${gse}/${cell}/splits"
    awk 'BEGIN {total=0; check=0}
         FILENAME ~ /_linecount.txt$/ {total += $1/4; next}
         FILENAME ~ /norm.*res/ {check += $2; next}
         END {if (total != check) print "'"$gse"'\t'"$cell"'" >> "'"$output_file"'"}
    ' ${splitdir}/*_linecount.txt ${splitdir}/*norm*res*
done < "$filelist"


# # 找到正确
# wctotal=`cat ${splitdir}/*_linecount.txt | awk '{sum+=$1}END{print sum/4}'`
# check2=`cat ${splitdir}/*norm*res* | awk '{s2+=$2;}END{print s2}'`
