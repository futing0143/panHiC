#!/bin/bash


wkdir=/cluster2/home/futing/Project/panCancer/CML
cancer=CML
output_file=${wkdir}/check/check_July06.txt
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

IFS=$','
while read -r gse cell other;do
	dir=${wkdir}/${gse}/${cell}
	check_file ${dir}/aligned/inter_30.hic
	check_file ${dir}/cool/${cell}.mcool
	check_file ${dir}/cool/${cell}_2500000.cool
	# check_file ${dir}/splits/*.fastq.gz.sam
	check_file $dir/anno/cooltools/dots.5000.tsv
	check_file $dir/anno/fithic/outputs/5000/${cell}.intraOnly/${cell}.fithic.bed
	check_file $dir/anno/mustache/${cell}_5kb_mustache.bedpe
	check_file $dir/anno/OnTAD/${cell}_50000.bed
	check_file $dir/anno/peakachu/${cell}-peakachu-5kb-loops.0.95.bedpe
	check_file $dir/anno/stripecaller/${cell}.bed
	check_file $dir/anno/stripenn/result_filtered.tsv
	check_file $dir/anno/insul/${cell}_5000.tsv
done < "${wkdir}/meta/${cancer}_meta.txt"

# 移动错误的 stripecaller 命名
# IFS=$','
# while read -r gse cell other;do
# 	file=${wkdir}/${gse}/${cell}/anno/stripecaller
# 	if [ -s $file ];then
		
# 		mv $file ${file}.bed
# 		mkdir -p ${wkdir}/${gse}/${cell}/anno/stripecaller
# 		mv ${file}.bed ${file}/${cell}.bed
# 	fi
# done < "${wkdir}/meta/${cell}_meta.txt"




