#!/bin/bash
set -euo pipefail
d=$1

# 输出文件
output_file=/cluster2/home/futing/Project/panCancer/check/unpost/unpost_${d}.txt
hic_file=/cluster2/home/futing/Project/panCancer/check/post/hicdone${d}.txt
> "$output_file"
> "$hic_file"

# 进度文件
total=$(wc -l < "/cluster2/home/futing/Project/panCancer/check/aligned/realalign${d}.txt")
progress_file=$(mktemp)
echo 0 > "$progress_file"

# 检查单个文件函数
check_file() {
    local file="$1"
    local cancer="$2"
    local gse="$3"
    local cell="$4"
    local output_tmp="$5"  # 临时文件
    local hic_tmp="$6"     # 临时文件

    local tools
	tools=$(awk -F '/' '{print $11}' <<< ${file})
    if [ ! -e "$file" ] || [ ! -s "$file" ]; then
        echo -e "${cancer}\t${gse}\t${cell}\t${tools}" >> "$output_tmp"
    else
        echo -e "${cancer}\t${gse}\t${cell}\t${tools}" >> "$hic_tmp"
    fi
}

export -f check_file

# 检查每个样本
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
    local tmp_hic=$(mktemp)

    # 遍历文件列表安全调用 check_file
    for f in "${dir}/aligned/inter_30.hic" \
             "${dir}/cool/${cell}.mcool" \
             "${dir}/cool/${cell}_2500000.cool" \
             "${dir}/anno/${cell}_cis_100k.cis.vecs.tsv" \
             "${dir}/anno/cooltools/dots.5000.tsv" \
             "${dir}/anno/fithic/outputs/5000/${cell}.intraOnly/${cell}.fithic.bed" \
             "${dir}/anno/mustache/${cell}_5kb_mustache.bedpe" \
             "${dir}/anno/OnTAD/${cell}_50000.bed" \
             "${dir}/anno/peakachu/${cell}-peakachu-5kb-loops.0.95.bedpe" \
             "${dir}/anno/stripecaller/${cell}.bed" \
             "${dir}/anno/stripenn/result_filtered.tsv" \
             "${dir}/anno/insul/${cell}_5000.tsv" \
             "${dir}/anno/SV/${cell}.assemblies.txt"; do
        check_file "$f" "$cancer" "$gse" "$cell" "$tmp_output" "$tmp_hic"
    done

    # 将临时文件合并到全局文件，避免并行冲突
    cat "$tmp_output" >> "$output_file"
    cat "$tmp_hic" >> "$hic_file"
    rm -f "$tmp_output" "$tmp_hic"
}

export -f check_one
export output_file hic_file progress_file total

# 并行执行
xargs -a "/cluster2/home/futing/Project/panCancer/check/aligned/realalign${d}.txt" -n3 -P10 bash -c 'check_one "$@"' _

# 清理进度文件
rm -f "$progress_file" "$progress_file.lock"

echo "✅ All done. Results:"
echo "  - Unpost: $output_file"
echo "  - Post:   $hic_file"

# 最后修改 unpost 文件
awk -F'\t' '{
    if ($0 ~ /cis_100k\.cis\.vecs\.tsv/) {
        $NF = "PC"
    }
    OFS = "\t"
    print
}' "$output_file" > tmp && mv tmp "$output_file"
