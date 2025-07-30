#!/bin/bash


check_file() {
    local file="$1"
    if [ -e "$file" ] && [ -s "$file" ]; then
        return 0    # 存在且非空
    else
        return 1    # 不存在或为空
    fi
}
cell="TALL"
wkdir=/cluster2/home/futing/Project/panCancer/${cell}
output_file=${wkdir}/check/${cell}_hic.txt
filelist=${wkdir}/meta/${cell}_meta.txt
>${output_file}
IFS=$','
while read -r gse cell other;do
	hic_exist=false
	f="${wkdir}/${gse}/${cell}/aligned/inter_30.hic"
	[ -e "$f" ] && check_file "$f" && hic_exist=true
	if ! $hic_exist;then
		echo -e "${gse}\t${cell}" >> $output_file
	fi
done < "$filelist"

