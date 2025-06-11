#!/bin/bash

file=/cluster/home/futing/Project/panCancer/CRC/04CRC_anno.csv
cd /cluster/home/futing/Project/panCancer/CRC
IFS=$','
while read -r gse gsm srr cell other;do
    gse=$(echo "$gse" | tr -d '[:space:]')
    cell=$(echo "$cell" | tr -d '[:space:]')
    srr=$(echo "$srr" | tr -d '[:space:]')
	if [ ! -d ${gse}/${cell} ];then
		echo -e "...Creating directory: ${gse}/${cell}"
		echo -e "...Moving files from ${srr} to ${gse}/${cell}\n"
		mkdir -p ${gse}/${cell}
		mv ${srr}/* ${gse}/${cell}/
	else
		echo "Directory already exists: ${gse}/${cell}"
		mv ${srr}/* ${gse}/${cell}/
	fi

done < <(tail -n +2 "$file")

# find . -type d -empty -delete

# 检查post部分的输出
output_file=/cluster/home/futing/Project/panCancer/CRC/check/CRC_meta_runpost_check3.txt
check_file() {
	local file="$1"

	# 检查文件是否存在
	if [ ! -e "$file" ]; then
		tools=$(awk -F '/' '{print $11}' <<< ${file})
		cell=$(awk -F '/' '{print $9}' <<< ${dir})
		echo -e "$cell\t$tools" >> "$output_file"
	# 检查文件是否为空
	elif [ ! -s "$file" ]; then
		tools=$(awk -F '/' '{print $11}' <<< ${file})
		cell=$(awk -F '/' '{print $9}' <<< ${dir})
		echo -e "$cell\t$tools" >> "$output_file"
	fi
}
# 主程序
# 示例：检查单个文件
check_file $dir/anno/cooltools/dots.5000.tsv

IFS=$','
while read -r gse cell other;do
	dir=/cluster/home/futing/Project/panCancer/CRC/GSE137188/${cell}
	check_file $dir/anno/cooltools/dots.5000.tsv
	check_file $dir/anno/fithic/outputs/5000/${cell}.intraOnly/${cell}.fithic.bed
	check_file $dir/anno/mustache/${cell}_5kb_mustache.bedpe
	check_file $dir/anno/OnTAD/${cell}_50000.bed
	check_file $dir/anno/peakachu/${cell}-peakachu-5kb-loops.0.95.bedpe
	check_file $dir/anno/stripecaller/${cell}
	check_file $dir/anno/stripenn/result_filtered.tsv
done < "/cluster/home/futing/Project/panCancer/CRC/CRC_meta_runpost.txt"
