#!/bin/bash
d=$1
cd /cluster2/home/futing/Project/panCancer/check

# ===== 路径设置 =====
unalign=/cluster2/home/futing/Project/panCancer/check/aligned/unalign/unalign${d}.txt
unrun_file=/cluster2/home/futing/Project/panCancer/check/unrun/unrun${d}.txt
aligndone=/cluster2/home/futing/Project/panCancer/check/aligned/aligndone${d}.txt
filelist=/cluster2/home/futing/Project/panCancer/check/meta/panCan_meta.txt

> "$unalign"
> "$unrun_file"
> "$aligndone"

# ===== 计算总任务数并初始化进度文件 =====
total=$(wc -l < "$filelist")
progress_file=$(mktemp)
echo 0 > "$progress_file"

export unalign unrun_file aligndone progress_file total

check_one() {
    local cancer="$1"
    local gse="$2"
    local cell="$3"
    local splitdir="/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}/splits"

    # --- 更新进度 ---
    {
        n=$(<"$progress_file")
        echo $((n + 1)) > "$progress_file"
    } 200>"$progress_file.lock"

    local current=$(<"$progress_file")
    printf "[ %3d / %3d ] Checking %s/%s/%s\n" "$current" "$total" "$cancer" "$gse" "$cell"

    # --- 检查是否有sam文件 ---
	if ! compgen -G "${splitdir}/*.sam" > /dev/null && ! compgen -G "${splitdir}/*.bam" > /dev/null; then
		echo -e "${cancer}\t${gse}\t${cell}" >> "$unrun_file"
		return
	fi

    # --- 比较 linecount 与 norm 结果 ---
    awk -v cancer="$cancer" -v gse="$gse" -v cell="$cell" \
        -v unalign="$unalign" \
        -v done_file="$aligndone" '
        BEGIN {total=0; check=0}
        {
            if (ARGIND == 1) { total += $1/4 }
            if (ARGIND == 2) { check += $2 }
        }
        END {
            if (total != check) {
                print cancer "\t" gse "\t" cell >> unalign
            } else {
                print cancer "\t" gse "\t" cell >> done_file
            }
        }
    ' <(zcat -f "${splitdir}"/*_linecount.txt* 2>/dev/null) <(zcat -f "${splitdir}"/*norm*res*.txt* 2>/dev/null)
}

export -f check_one

# ===== 并行执行 =====
cut -f1-3 "$filelist" | xargs -P 8 -n3 bash -c 'check_one "$@"' _



echo "✅ All done. Results:"
echo "  - Unaligned: $unalign"
echo "  - Unrun:     $unrun_file"
echo "  - Done:      $aligndone"

# ===== 清理临时文件 =====
rm -f "$progress_file" "$progress_file.lock"

# ==== 添加不需要 align 的结果到 $aligndone 文件中
echo -e "AML\tGSE152136\tPBMC_BM1" >> ${aligndone}
echo -e "AML\tGSE152136\tPBMC_BM2" >> ${aligndone}
echo -e "AML\tGSE152136\tPBMC_BM3" >> ${aligndone}
grep -E 'GBM|GSE207951' ${unalign} >> ${aligndone} # EGA 的有问题，直接修改
grep -E 'GSE229962|GSE162976|GSE207951' ${unrun_file} >> ${aligndone} # NC;pHGG;CRC mHiC
sort -k1 -k2 -k3 ${aligndone} > ./aligned/tmp && mv ./aligned/tmp ${aligndone}

# ===== 去除不需要align的结果
grep -Ev 'GSE229962|GSE162976|GSE207951' ${unrun_file} > tmp && mv tmp ${unrun_file} # 
grep -v 'GBM' ${unalign} > tmp && mv tmp ${unalign}  #删掉 aligned 里面的 cell_line

# grep -F -w -v -f ./download/err_dir${d}.txt ${aligndone} > ./aligned/realalign${d}.txt
