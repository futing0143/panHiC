#!/bin/bash
#SBATCH -p normal
#SBATCH --cpus-per-task=30
#SBATCH --output=/cluster2/home/futing/Project/panCancer/check/sam2bam/debug/sam2bam-%j.log
#SBATCH -J "sam2bam"
ulimit -s unlimited
ulimit -l unlimited

# =================
# Description: Convert SAM files to BAM format with proper headers.
# 2026.1.14 by futing
# =================

# 定义包含SAM文件的根目录
source activate /cluster2/home/futing/miniforge3/envs/juicer
# samtools install samtools -y
# d=1123
convertfile="/cluster2/home/futing/Project/panCancer/check/meta/panCan_down_sim.txt"

convert_func() {
    cancer=$1
    gse=$2
    cell=$3
    srr=$4
    root_directory=/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}/splits
    log_dir=/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}/debug
    log_file=${log_dir}/${srr}-sam2bam-$(date).log

    mkdir -p "$log_dir"
    {
	echo "=========================================="
	echo "Start: $(date)"
	echo "Processing ${cancer}/${gse}/${cell}/${srr}"
	echo "Root dir: ${root_directory}"
	echo "=========================================="

    if ! command -v samtools &> /dev/null; then
        echo "samtools could not be found, please install it first."
        return 1
    fi

    # 主文件前缀
    prefix="${root_directory}/${srr}.fastq.gz"

    # 主 BAM（header 来源）
    ref_bam="${prefix}.bam"

    if [[ ! -s "$ref_bam" ]]; then
        echo "ERROR: reference BAM not found: $ref_bam"
        return 1
    fi

    # 要处理的 SAM 列表
    sam_list=(
        "${prefix}.sam"
        "${prefix}_unmapped.sam"
        "${prefix}_abnorm.sam"
    )

    for sam in "${sam_list[@]}"; do
        # 跳过不存在或空文件
        [[ -s "$sam" ]] || continue

        echo "Converting: $sam"

        out_bam="${sam%.sam}.bam"

        # 主 SAM 通常自带 header，可直接转
        if [[ "$sam" == "${prefix}.sam" ]]; then
            samtools view -@ 10 -bS "$sam" > "$out_bam" && \
            rm "$sam" && \
            echo "Created BAM: $out_bam"
            continue
        fi

        # unmapped / abnorm：补 header
		header_tmp=$(mktemp "${log_dir}/header.XXXXXX")
		fixed_sam=$(mktemp "${log_dir}/fixed.XXXXXX")

        samtools view -H "$ref_bam" > "$header_tmp"
        cat "$header_tmp" "$sam" > "$fixed_sam"

        samtools view -@ 20 -bS "$fixed_sam" > "$out_bam" && \
		samtools quickcheck "$out_bam" && \
        rm "$sam" && \
        echo "Created BAM: $out_bam"

        rm -f "$header_tmp" "$fixed_sam"
    done
	
	} > "${log_file}" 2>&1
}

export -f convert_func

parallel -j 5 --colsep '\t' --progress --eta \
	"convert_func {1} {2} {3} {4}" :::: "$convertfile"
