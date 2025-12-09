#!/bin/bash
d=$1
cd /cluster2/home/futing/Project/panCancer/check
blacklist=/cluster2/home/futing/Project/panCancer/check/meta/blacklist.txt
blacklist5k='/cluster2/home/futing/Project/panCancer/check/unpost/loops/loops5k_blacklist.txt'
blacklist10k='/cluster2/home/futing/Project/panCancer/check/unpost/loops/loops10k_blacklist.txt'

err_file="/cluster2/home/futing/Project/panCancer/check/download/err_dir${d}.txt" # SRR对不上的
alignfail=/cluster2/home/futing/Project/panCancer/check/aligned/unalign/unalign${d}.txt # splits 文件有问题的：CRC7个，AML3个，GBM NC28 & EGA21
unalign=/cluster2/home/futing/Project/panCancer/check/unrun/unrun${d}.txt #没有splits
aligndone=/cluster2/home/futing/Project/panCancer/check/${aligndone} # splits没有问题
unpost=/cluster2/home/futing/Project/panCancer/check/unpost/all/unpost_${d}.txt # 从aligndone挑选的
postdone=/cluster2/home/futing/Project/panCancer/check/post/all/hicdone${d}.txt


: << 'EOF'
# ----------  01 单独处理post
# PC insul cooltools peakachu mustache (fithic OnTAD stripecaller stripenn)

grep -Ev 'SV|\.mcool|\.cool|inter_30\.hic|stripenn|PBMC_BM' \
    ${unpost} | \
    grep -v -w -F -f ${blacklist5k} | \
    sort -u > ./unpost/loops/loops5k_${d}.txt

# ---------- 02 综合检查各个步骤的结果，划分不同情况
# p1.1 下载完了，没跑
grep -F -w -v -f ${err_file} ${unalign}
# p1.2 没下载，没跑
grep -F -f ${err_file} ${unalign}

# p2 没下载，跑了一半；有sam但fastq不齐
grep -F -f ${aligndone} ${err_file}

# p3 下载完了 aligned有问题
head ${alignfail}


# p4.1 下载完了 aligned 但没有hic
# ! 从aligndone + 没有 hic 中去掉没下载的，需要挂final任务
grep -F -w -v -f <(grep 'inter_30.hic' ./post/hicdone${d}.txt | cut -f1-3) ./${aligndone} > ./unpost/hicundone/hicundone${d}.txt
# hic没有完成
head ./unpost/hicundone/hicundone${d}.txt

# p4.2 从 hicdone 中去掉没下载的，找到没cool的
grep -F -f <(grep '.mcool' ${unpost} | cut -f1-3) \
	<(grep 'inter_30.hic' ./post/hicdone${d}.txt | cut -f1-3)
# 找到hicdone
grep 'inter_30.hic' ./post/hicdone${d}.txt | cut -f1-3 > ./sam2bam/sam2bam_${d}.txt
# 没跑完的
grep -w -v -F -f ./sam2bam/sam2bam_${d}.txt ./meta/panCan_meta.txt

# ---------- 03 查找补充运行 insul loops ----
# -------- 挑选出没有 50k insul 

# 重新检查SV的问题

grep 'SV' ${unpost} > /cluster2/home/futing/Project/panCancer/Analysis/SV/meta/unSV/SV_${d}.txt

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
done_file=./post/loops/loops10k_done${d}.txt
>$done_file
total=$(wc -l < <(grep '\.cool' "./post/hicdone${d}.txt"))
progress_file=$(mktemp)
echo 0 > "$progress_file"

check_file() {
    local file="$1"
    local cancer="$2"
    local gse="$3"
    local cell="$4"
    local output_tmp="$5"  # 临时文件
	local done_tmp="$6"

    local tools
	# tools=$(dirname ${file} | xargs -n1 basename)
	tools=$(cut -f11 -d '/' <<< "${file}")
    if [ ! -e "$file" ] || [ ! -s "$file" ]; then
        echo -e "${cancer}\t${gse}\t${cell}\t${tools}" >> "$output_tmp"
    else
		echo -e "${cancer}\t${gse}\t${cell}\t${tools}" >> "$done_tmp"
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
	local tmp_done=$(mktemp)

    # 遍历文件列表安全调用 check_file
    for f in $dir/anno/cooltools/dots.10000.tsv \
             $dir/anno/fithic/outputs/10000/${cell}_0.2.intraOnly/${cell}.fithic.bed \
             $dir/anno/mustache/${cell}_10kb_mustache.bedpe \
             $dir/anno/peakachu/${cell}-peakachu-10kb-loops.0.95.bedpe; do
        check_file "$f" "$cancer" "$gse" "$cell" "$tmp_output" "$tmp_done"
    done

    # 将临时文件合并到全局文件，避免并行冲突
    cat "$tmp_output" >> "$output_file"
	cat "$tmp_done" >> "$done_file"
    rm -f "$tmp_output" "$tmp_done"
}

export -f check_one
export output_file done_file progress_file total

grep '\.cool' ./post/hicdone${d}.txt | cut -f1-3 |\
	xargs -n3 -P10 bash -c 'check_one "$1" "$2" "$3"' _

echo "-----------------------------------"
echo "Done checking loops 10k missing."
echo "file: $output_file"

# grep -v "peakachu" $outputfile > tmp && mv tmp $outputfile
grep -v -w -F -f ${blacklist} \
	$output_file | grep -Ev 'PBMC_BM2|PBMC_BM1|PBMC_BM3' > tmp && mv tmp $output_file

:<< 'EOF'
grep 'fithic' $output_file > tmp && mv tmp $output_file

# fix fithic 1109 挑选特定类型删除
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


# fix fithic 改输出名称

res=5000
x=0.2
IFS=$'\t'
while read -r cancer gse cell tools;do

	dir=/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}
	echo -e "mv ${dir}/anno/fithic/outputs/${res}/${cell}.intraOnly/ \
		${dir}/anno/fithic/outputs/${res}/${cell}_${x}.intraOnly/ \n"
	mv ${dir}/anno/fithic/outputs/${res}/${cell}.intraOnly \
		${dir}/anno/fithic/outputs/${res}/${cell}_${x}.intraOnly
done < <(grep 'fithic' ./post/hicdone${d}.txt)


while read -r cancer gse cell other;do
> dir="/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}"
> fithicdir=$dir/anno/fithic/outputs/10000/${cell}.intraOnly
> newdir=$dir/anno/fithic/outputs/10000/${cell}_0.2.intraOnly
> if [ -d "$fithicdir" ];then
> mv $fithicdir $newdir
> fi
> done < <(grep '\.cool' "./post/hicdone${d}.txt")

# ------- 解压 SV 结果
while read -r cancer gse cell;do 
dir=/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}
echo $dir 
find ${dir}/anno/SV -type f -name '*.txt.gz' -exec gunzip {} \;
done < "/cluster2/home/futing/Project/panCancer/Analysis/SV/SV_unrun${d}.txt"

EOF

