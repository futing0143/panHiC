#!/bin/bash
set -euo pipefail  # 更严格的错误处理

# 参数检查
if [ $# -lt 1 ]; then
    echo "Usage: $0 <directory> [resolution=5000]"
    exit 1
fi

dir="$1"
reso="${2:-5000}"
name=$(basename "$dir")

# 验证分辨率
if ! [[ "$reso" =~ ^[0-9]+$ ]] || [ "$reso" -le 0 ]; then
    echo "Error: Resolution must be a positive integer"
    exit 1
fi

source activate peakachu
coolfile="${dir}/cool/${name}_${reso}.cool"

# 创建输出目录
mkdir -p "${dir}/anno/peakachu" || {
    echo "Error: Failed to create output directory"
    exit 1
}
cd "${dir}/anno/peakachu" || {
    echo "Error: Failed to change directory"
    exit 1
}

echo -e "\nProcessing $name at $reso using peakachu call dots..."

# 计算分辨率kb值
reso_kb=$((reso / 1000))

# calculate depth
cleanfile="./${name}_${reso_kb}kb_clean.txt"
depthfile="./${name}_${reso_kb}kb.txt"

if [ -e "${depthfile}" ] && [ -s "${depthfile}" ]; then
    echo "${name}_${reso_kb}kb.txt exists, skip..."
else
    echo "${name}" > "${depthfile}"
    peakachu depth -p "${coolfile}" >> "${depthfile}" || {
        echo "Error: peakachu depth failed"
        exit 1
    }

    line_count=$(wc -l < "${depthfile}")

    if [ "$line_count" -le 1 ]; then
        echo "depth not completed, exiting..."
        exit 1
    fi
fi
awk '
	BEGIN {
		OFS = "\t"
	}
	NR == 1 {
		name = $0
	}
	END {
		model = $0
		sub(/^.*: /, "", model)
		gsub(/ /, "", model)
		print name, model
	}
' "${depthfile}" > "${cleanfile}" || {
	echo "Error: Failed to process depth file"
	exit 1
}


# running peakachu
while read -r file depth; do
    echo "Processing ${file} at ${depth}..."
    output_file="${file}-peakachu-${reso_kb}kb-scores.bedpe"
    final_output="${file}-peakachu-${reso_kb}kb-loops.0.95.bedpe"
    
    if [ -f "${final_output}" ]; then
        echo "${final_output} exists, skip..."
		continue
    fi
    
    if [ ! -f "${output_file}" ]; then
        weight="/cluster/home/futing/Project/GBM/HiC/10loop/peakachu/peakachu/high-confidence.${depth}.${reso_kb}kb.w6.pkl"
        
        if [ ! -e "${weight}" ]; then
            echo "Weight file ${weight} does not exist, please check!"
            exit 1
        fi
        
        peakachu score_genome -r "${reso}" --clr-weight-name weight \
            -p "${coolfile}" \
            -O "${output_file}" \
            -m "${weight}" || {
                echo "***! Problem while running peakachu score_genome"
                exit 1
            }
    fi

    peakachu pool -r "${reso}" \
        -i "${output_file}" \
        -o "${final_output}" -t 0.95 || {
            echo "***! Problem while running peakachu pool"
            exit 1
        }

done < "${cleanfile}"

echo -e "Peakachu finished successfully for ${name} at ${reso} resolution!!!\n"
