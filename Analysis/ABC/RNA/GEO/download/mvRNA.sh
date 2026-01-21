#!/bin/bash
# set -euo pipefail

wkdir=/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO
meta=/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/00meta/RNA_GSE_srr.txt
src=/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/download
done_srr=/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/download/dumpdone0117nig.txt
test=/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/00meta/RNA_GSE_srrtest.txt

# ===== 处理单个记录的函数 =====
process_record() {
    local cancer="$1"
    local gsm="$2"
    local srrs="$3"
    
    echo "Processing cancer='$cancer' gsm='${gsm:-NA}' srrs='${srrs:-NA}'"
    
    if [[ -z "${gsm}" || -z "${srrs}" ]]; then
        echo "[SKIP_EMPTY] $cancer gsm='${gsm:-NA}' srr='${srrs:-NA}'"
        return 0
    fi

    outdir=${wkdir}/${cancer}/fastq
    mkdir -p "$outdir"

    # SRR 拆分
    local IFS=';'
    local -a SRR_ARR=($srrs)  # 注意：这里假设 srrs 中没有空格等特殊字符
    
    # 检查 SRR 是否齐全
    local missing=()
    for srr in "${SRR_ARR[@]}"; do
        if ! grep -qx "$srr" "$done_srr"; then
            missing+=("$srr")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "[INCOMPLETE] $cancer $gsm missing: ${missing[*]}"
        return 0
    fi

    # 判断 SE / PE
    local has_R1 has_R2
    has_R1=$(ls ${src}/${SRR_ARR[0]}*_1*.fastq.gz 2>/dev/null | wc -l)
    has_R2=$(ls ${src}/${SRR_ARR[0]}*_2*.fastq.gz 2>/dev/null | wc -l)

    if [[ $has_R1 -gt 0 && $has_R2 -gt 0 ]]; then
        echo "[PE] $gsm -> $cancer"
        echo "cat ${SRR_ARR[@]/#/${src}/}_1*.fastq.gz \
            > ${outdir}/${gsm}_1.fastq.gz"
    else
        echo "[SE] $gsm -> $cancer"
        echo "cat ${SRR_ARR[@]/#/${src}/}*.fastq.gz \
            > ${outdir}/${gsm}.fastq.gz"
    fi
}

# ===== 主循环 =====
while IFS=$'\t' read -r cancer gsm srrs; do
    process_record "$cancer" "$gsm" "$srrs"
done < <(
    awk 'BEGIN{FS=OFS="\t"}
    {
        cancer=$3;
        gsm=$6;
        srr=$7;
        print cancer, gsm, srr
    }' "$test"
)