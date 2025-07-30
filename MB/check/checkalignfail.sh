#!/bin/bash


check_file() {
    local file="$1"
    if [ -e "$file" ] && [ -s "$file" ]; then
        return 0    # 存在且非空
    else
        return 1    # 不存在或为空
    fi
}
cancer=MB
output_file=/cluster2/home/futing/Project/panCancer/${cancer}/check/${cancer}_align.txt
filelist=/cluster2/home/futing/Project/panCancer/${cancer}/meta/${cancer}_meta.txt
>${output_file}

IFS=$','
while read -r gse cell other; do
    splitdir="/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}/splits"
    awk 'BEGIN {total=0; check=0}
         FILENAME ~ /_linecount.txt$/ {total += $1/4; next}
         FILENAME ~ /norm.*res/ {check += $2; next}
         END {if (total != check) print "'"$gse"'\t'"$cell"'" >> "'"$output_file"'"}
    ' ${splitdir}/*_linecount.txt ${splitdir}/*norm*res*
done < "$filelist"



# wctotal=`cat ${splitdir}/*_linecount.txt | awk '{sum+=$1}END{print sum/4}'`
# check2=`cat ${splitdir}/*norm*res* | awk '{s2+=$2;}END{print s2}'`
 
