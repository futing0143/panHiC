#!/bin/bash
d=$1
cd /cluster2/home/futing/Project/panCancer/check
: << 'EOF'
# ----------  01 单独处理post
# PC insul cooltools peakachu mustache (fithic OnTAD stripecaller stripenn)

awk -F'\t' '{
    if ($0 ~ /cis_100k\.cis\.vecs\.tsv/) {
        $NF = "PC"
    }
    OFS = "\t"
    print
}' ./unpost/unpost_${d}.txt > tmp && mv tmp ./unpost/unpost_${d}.txt

grep -v -e 'SV' -e '\.mcool' -e '\.cool' -e 'inter_30.hic' -e 'stripenn' \
	-e 'peakachu' -e 'mustache' \
    ./unpost/unpost_${d}.txt | \
    grep -v -w -F -f /cluster2/home/futing/Project/panCancer/Analysis/SV/meta/blacklist.txt | \
    sort -u > ./unpost/loops/loops5k_${d}.txt


awk 'BEGIN{FS=OFS="\t"}{if ($4=="PC") print $1,$2,$3}' ./unpost/unpost_${d}.txt \
	> ./unpost/PC/PCundone${d}.txt
awk 'BEGIN{FS=OFS="\t"}{if ($4=="cooltools") print $1,$2,$3,"dots"}' ./unpost/unpost_${d}.txt \
	> ./unpost/loops/dots5k${d}.txt
awk 'BEGIN{FS=OFS="\t"}{if ($4=="insul") print $1,$2,$3,"insul"}' ./unpost/unpost_${d}.txt \
	> ./unpost/loops/insul5k${d}.txt

# ---------- 02 综合检查各个步骤的结果，划分不同情况
# p1 下载完了，没跑
grep -F -w -v -f ./download/err_dir${d}.txt ./unrun/unrun${d}.txt

# p2.1 没下载,没跑
grep -F -f ./download/err_dir${d}.txt ./unrun/unrun${d}.txt
# p2.2 没下载，跑了一半
grep -F -f aligned/aligndone${d}.txt ./download/err_dir${d}.txt
# grep -v -w -F -f ./unrun/unrun${d}.txt ./download/err_dir${d}.txt

# p2.1 下载完了 aligned有问题
head ./aligned/unalign${d}.txt

# p2.2 下载完了，aligned，但没有hic
# ! 从aligndone + 没有 hic 中去掉没下载的，需要挂final任务
grep -F -w -v -f <(grep 'inter_30.hic' ./post/hicdone${d}.txt | cut -f1-3) ./aligned/realalign${d}.txt > ./post/hicundone${d}.txt

# p3.1 从 hicdone 中去掉没下载的，找到没cool的
grep -F -f <(grep '.mcool' ./unpost/unpost_${d}.txt | cut -f1-3) \
	<(grep 'inter_30.hic' ./post/hicdone${d}.txt | cut -f1-3)
# 找到hicdone
grep 'inter_30.hic' ./post/hicdone${d}.txt | cut -f1-3 > ./sam2bam/sam2bam_${d}.txt
# 没跑完的
grep -w -v -F -f ./sam2bam/sam2bam_${d}.txt ./meta/panCan_meta.txt

# ---------- 03 查找补充运行 insul loops ----
# -------- 挑选出没有 50k insul 
output_file=./unpost/insul/insul50k_${d}.txt
>$output_file
IFS=$'\t'
while read -r cancer gse cell other;do
	dir=/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}
	splitdir="/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}/splits"
	file=$dir/anno/insul/${cell}_50000.tsv
	tools="insul"
	if [ ! -e "$file" ] || [ ! -s "$file" ]; then
		echo -e "${cancer}\t$gse\t$cell\t$tools" >> "$output_file"
	else
		echo -e "${cancer}\t$gse\t$cell\t$tools exists" 

	fi
done < <(grep '_2500000.cool' ./post/hicdone${d}.txt)

# 重新检查SV的问题

grep 'SV' ./unpost/unpost_${d}.txt > /cluster2/home/futing/Project/panCancer/Analysis/SV/meta/unSV/SV_${d}.txt

> "/cluster2/home/futing/Project/panCancer/Analysis/SV/SV_post${d}.txt"
IFS=$'\t'
while read -r cancer gse cell other;do

	dir=/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}
	file1=${dir}/anno/SV/${cell}.SV_calls.reformat.txt
	file2=${dir}/anno/SV/${cell}.assemblies.txt
	file3=${dir}/anno/SV/${cell}.SV_calls.txt
	if [ -f ${file1} ] && [ ! -f ${file2} ];then
		echo -e "${cancer}\t${gse}\t${cell}" >> /cluster2/home/futing/Project/panCancer/Analysis/SV/SV_post${d}.txt
	fi
done < <(grep 'SV' ./post/hicdone${d}.txt)

EOF
# ------- 挑选出 loops 10k 没跑的
output_file=./unpost/loops/loops10k_${d}.txt
>$output_file
total=$(wc -l < <(grep '_2500000.cool' "./post/hicdone1106.txt"))
progress_file=$(mktemp)
echo 0 > "$progress_file"

check_file() {
    local file="$1"
    local cancer="$2"
    local gse="$3"
    local cell="$4"
    local output_tmp="$5"  # 临时文件

    local tools
	# tools=$(dirname ${file} | xargs -n1 basename)
	tools=$(cut -f11 -d '/' <<< "${file}")
    if [ ! -e "$file" ] || [ ! -s "$file" ]; then
        echo -e "${cancer}\t${gse}\t${cell}\t${tools}" >> "$output_tmp"
    fi
}
export -f check_file

check_one() {
    local cancer="$1"
    local gse="$2"
    local cell="$3"
    local dir="/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}"

    # 进度条更新
    {
        n=$(<"$progress_file")
        echo $((n + 1)) > "$progress_file"
    } 200>"$progress_file.lock"
    local current=$(<"$progress_file")
    printf "[ %3d / %3d ] Checking %s/%s/%s\n" "$current" "$total" "$cancer" "$gse" "$cell"

    # 临时文件保存当前进程结果
    local tmp_output=$(mktemp)

    # 遍历文件列表安全调用 check_file
    for f in $dir/anno/cooltools/dots.10000.tsv \
             $dir/anno/fithic/outputs/10000/${cell}.intraOnly/${cell}.fithic.bed \
             $dir/anno/mustache/${cell}_10kb_mustache.bedpe \
             $dir/anno/peakachu/${cell}-peakachu-10kb-loops.0.95.bedpe; do
        check_file "$f" "$cancer" "$gse" "$cell" "$tmp_output"
    done

    # 将临时文件合并到全局文件，避免并行冲突
    cat "$tmp_output" >> "$output_file"
    rm -f "$tmp_output"
}

export -f check_one
export output_file progress_file total

grep '_2500000.cool' ./post/hicdone1106.txt | cut -f1-3 |\
	xargs -n3 -P10 bash -c 'check_one "$1" "$2" "$3"' _

echo "done checking loops 10k missing."
echo "file: $output_file"

grep -v "peakachu" $outputfile > tmp && mv tmp $outputfile





:<< 'EOF'
# fix fithic 1109
while read -r cancer gse cell other; do
    dir="/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}"
    
    # 更宽松的错误模式匹配
    if grep -rl "unexpected end of file" "${dir}/debug/"*fithic*.log 2>/dev/null; then
        file_to_remove="${dir}/anno/fithic/outputs/5000/${cell}.intraOnly/${cell}.spline_pass1.res5000.significances.txt.gz"
        
        # 添加安全检查
        if [[ -f "$file_to_remove" ]]; then
            echo "Removing: $file_to_remove"
            rm "$file_to_remove"
        else
            echo "File not found: $file_to_remove"
        fi
    fi
done < <(grep 'fithic' ./unpost/loops/loops5k_1109.txt)
EOF