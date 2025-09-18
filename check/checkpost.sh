#!/bin/bash
d=$1
# 检查post部分的输出
output_file=/cluster2/home/futing/Project/panCancer/check/post/unpost_${d}.txt
>${output_file}
# unrun_file=/cluster2/home/futing/Project/panCancer/check/unrunpost${d}.txt
# >${unrun_file}
hic_file=/cluster2/home/futing/Project/panCancer/check/hic/hicdone${d}.txt
>${hic_file}

check_file() {
	local file="$1"
	# 检查文件是否存在
	tools=$(awk -F '/' '{print $11}' <<< ${file})
	cell=$(awk -F '/' '{print $9}' <<< ${dir})
	gse=$(awk -F '/' '{print $8}' <<< ${dir})
	cancer=$(awk -F '/' '{print $7}' <<< ${dir})
	if [ ! -e "$file" ] || [ ! -s "$file" ]; then
		echo -e "${cancer}\t$gse\t$cell\t$tools" >> "$output_file"
	else
		echo -e "${cancer}\t$gse\t$cell\t$tools" >> "$hic_file"

	fi
}

IFS=$'\t'
while read -r cancer gse cell other;do
	dir=/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}
	splitdir="/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}/splits"

	# if [ ! -d "$splitdir" ]; then
	# 	echo -e "${cancer}\t${gse}\t${cell}" >> "$unrun_file"
	# else
		check_file ${dir}/aligned/inter_30.hic
		check_file ${dir}/cool/${cell}.mcool
		# check_file ${dir}/splits/*.fastq.gz.sam
		check_file ${dir}/cool/${cell}_2500000.cool
		check_file $dir/anno/cooltools/dots.5000.tsv
		check_file $dir/anno/fithic/outputs/5000/${cell}.intraOnly/${cell}.fithic.bed
		check_file $dir/anno/mustache/${cell}_5kb_mustache.bedpe
		check_file $dir/anno/OnTAD/${cell}_50000.bed
		check_file $dir/anno/peakachu/${cell}-peakachu-5kb-loops.0.95.bedpe
		check_file $dir/anno/stripecaller/${cell}.bed
		check_file $dir/anno/stripenn/result_filtered.tsv
		check_file $dir/anno/insul/${cell}_5000.tsv
	# fi
done < "/cluster2/home/futing/Project/panCancer/check/aligned/realalign${d}.txt"

: << 'EOF'
# p1 下载完了，没跑
grep -F -w -v -f ./download/err_dir${d}.txt ./aligned/unrun${d}.txt

# p2.1 没下载,没跑
grep -F -f ./download/err_dir${d}.txt ./aligned/unrun${d}.txt
# p2.2 没下载，跑了一半
grep -F -f aligned/aligndone${d}.txt ./download/err_dir${d}.txt
# grep -v -w -F -f ./aligned/unrun${d}.txt ./download/err_dir${d}.txt

# p2.1 下载完了 aligned有问题
vim ./aligned/unalign${d}.txt

# p2.2 下载完了，aligned，但没有hic
# ! 从aligndone + 没有 hic 中去掉没下载的，需要挂final任务
grep -F -w -v -f <(grep 'inter_30.hic' ./hic/hicdone${d}.txt | cut -f1-3) ./aligned/realalign${d}.txt > ./hic/hicundone${d}.txt



# p3.1 从 hicdone 中去掉没下载的，找到没cool的

grep -F -f <(grep '.mcool' ./post/unpost_${d}.txt | cut -f1-3) <(grep 'inter_30.hic' ./hic/hicdone${d}.txt | cut -f1-3)

EOF