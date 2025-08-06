#!/bin/bash


check_file() {
    local file="$1"
    if [ -e "$file" ] && [ -s "$file" ]; then
        return 0    # 存在且非空
    else
        return 1    # 不存在或为空
    fi
}
cancer=BRCA
output_file=/cluster2/home/futing/Project/panCancer/${cancer}/check/${cancer}_align0806.txt
filelist=/cluster2/home/futing/Project/panCancer/${cancer}/meta/${cancer}_meta.txt
>${output_file}
# IFS=$','
# while read -r gse cell other;do
# 	hic_exist=false
# 	f="/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}/aligned/inter_30.hic"
# 	[ -e "$f" ] && check_file "$f" && hic_exist=true
# 	if ! $hic_exist;then
# 		echo -e "${gse}\t${cell}" >> $output_file
# 	fi
# done < "$filelist"


IFS=$' '
while read -r gse cell other; do
    splitdir="/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}/splits"
    awk 'BEGIN {total=0; check=0}
         FILENAME ~ /_linecount.txt$/ {total += $1/4; next}
         FILENAME ~ /norm.*res/ {check += $2; next}
         END {if (total != check) print "'"$gse"'\t'"$cell"'" >> "'"$output_file"'"}
    ' ${splitdir}/*_linecount.txt ${splitdir}/*norm*res*
done < "$filelist"


# # 找到正确
i=SRR13755476
splitdir=/cluster2/home/futing/Project/panCancer/BRCA/GSE167150/Norm_patient4/splits
wctotal=`cat ${splitdir}/${i}.fastq.gz_linecount.txt | awk '{sum+=$1}END{print sum/4}'`
check2=`cat ${splitdir}/${i}.fastq.gz_norm.txt.res.txt | awk '{s2+=$2;}END{print s2}'`
echo $wctotal
echo $check2