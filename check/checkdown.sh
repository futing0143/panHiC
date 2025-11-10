#!/bin/bash
set -euo pipefail
d=$1

checklist=/cluster2/home/futing/Project/panCancer/check/meta/panCan_meta.txt
input=/cluster2/home/futing/Project/panCancer/check/meta/panCan_down_sim.txt
err_file="/cluster2/home/futing/Project/panCancer/check/download/err_dir${d}.txt"
> "$err_file"

cd /cluster2/home/futing/Project/panCancer/check
# ===== 计算总任务数并初始化进度文件 =====
total=$(wc -l < "$checklist")
progress_file=$(mktemp)
echo 0 > "$progress_file"

export input err_file progress_file total

check_one() {
    local cancer="$1"
    local gse="$2"
    local cell="$3"
    local dir="/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}"

    # --- 更新进度 ---
    {
        n=$(<"$progress_file")
        echo $((n + 1)) > "$progress_file"
    } 200>"$progress_file.lock"

    local current=$(<"$progress_file")
    printf "[ %3d / %3d ] Checking %s/%s/%s\n" "$current" "$total" "$cancer" "$gse" "$cell"

    if [ ! -d "$dir" ]; then
        echo -e "${cancer}\t${gse}\t${cell}" >> "$err_file"
        return
    fi

    local expected found
    expected=$(awk -v c="$cancer" -v g="$gse" -v cl="$cell" \
        '$1==c && $2==g && $3==cl {print $4}' "$input" | sort -u | tr '\n' ' ')
    found=$(find "$dir" -type f -name "*.fastq.gz" \
        | xargs -r -n1 basename \
        | sed 's/\.fastq\.gz$//' \
        | cut -d'_' -f1 \
        | sort -u | tr '\n' ' ')

    if [ "$expected" != "$found" ]; then
        echo -e "${cancer}\t${gse}\t${cell}" >> "$err_file"
    fi
}
export -f check_one

# cut -f1-3 "$checklist" | sort -u | parallel -j 10 check_one {1} {2} {3}

cut -f1-3 "$checklist" | sort -u | xargs -n3 -P 10 bash -c 'check_one "$@"' _

# grep -v 'PBMC_BM' $err_file > tmp && mv tmp $err_file

# ===== 清理临时文件 =====
rm -f "$progress_file" "$progress_file.lock"

echo "✅ All done. Results:"
echo " - err_file: $err_file"

