#!/bin/bash



dir=
output_file=/cluster2/home/futing/Project/panCancer/TALL/check/check_July03.txt
>${output_file}
check_file() {
	local file="$1"
	# 检查文件是否存在
	if [ ! -e "$file" ]; then
		tools=$(awk -F '/' '{print $11}' <<< ${file})
		cell=$(awk -F '/' '{print $9}' <<< ${dir})
		gse=$(awk -F '/' '{print $8}' <<< ${dir})
		echo -e "$gse\t$cell\t$tools" >> "$output_file"
	# 检查文件是否为空
	elif [ ! -s "$file" ]; then
		tools=$(awk -F '/' '{print $11}' <<< ${file})
		cell=$(awk -F '/' '{print $9}' <<< ${dir})
		gse=$(awk -F '/' '{print $8}' <<< ${dir})
		echo -e "$gse\t$cell\t$tools" >> "$output_file"
	fi
}


# check_file $dir/anno/cooltools/dots.5000.tsv
wkdir=/cluster2/home/futing/Project/panCancer/TALL
IFS=$','
while read -r gse cell other;do
	dir=${wkdir}/${gse}/${cell}
	check_file ${dir}/aligned/inter_30.hic
	check_file ${dir}/cool/*.mcool
	check_file ${dir}/splits/*.fastq.gz.sam
	check_file $dir/anno/cooltools/dots.5000.tsv
	check_file $dir/anno/fithic/outputs/5000/${cell}.intraOnly/${cell}.fithic.bed
	check_file $dir/anno/mustache/${cell}_5kb_mustache.bedpe
	check_file $dir/anno/OnTAD/${cell}_50000.bed
	check_file $dir/anno/peakachu/${cell}-peakachu-5kb-loops.0.95.bedpe
	check_file $dir/anno/stripecaller/${cell}.bed
	check_file $dir/anno/stripenn/result_filtered.tsv
	# if [ -e $dir/anno/stripecaller ] && [ -s $dir/anno/stripecaller ];then
	# 	mv $dir/anno/stripecaller $dir/anno/stripecaller.bed
	# 	mkdir -p $dir/anno/stripecaller/
	# 	mv $dir/anno/stripecaller.bed $dir/anno/stripecaller/${cell}.bed
	# fi

done < "${wkdir}/meta/TALL_meta.txt"
