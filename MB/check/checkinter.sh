#!/bin/bash


check_file() {
    local file="$1"
    if [ -e "$file" ] && [ -s "$file" ]; then
        return 0    # 存在且非空
    else
        return 1    # 不存在或为空
    fi
}

output_file=/cluster2/home/futing/Project/panCancer/MB/check/MB_hic.txt
filelist=/cluster2/home/futing/Project/panCancer/MB/meta/MBmeta_July02.txt #四列的文件

cut -f1,3,4 -d ',' /cluster2/home/futing/Project/panCancer/MB/meta/MB_July02.txt | sort | uniq > $filelist

>${output_file}
IFS=$','
while read -r gse cell other;do
	hic_exist=false
	f="/cluster2/home/futing/Project/panCancer/MB/${gse}/${cell}/aligned/inter_30.hic"
	[ -e "$f" ] && check_file "$f" && hic_exist=true
	if ! $hic_exist;then
		echo -e "${gse}\t${cell}" >> $output_file
	fi
done < "$filelist"

# find /cluster2/home/futing/Project/panCancer/MB/GSE240410 -name '*_R2.fastq.gz' -exec basename {} _R2.fastq.gz \; \
# 	| sort | uniq > /cluster2/home/futing/Project/panCancer/MB/check/done.txt