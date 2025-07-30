#!/bin/bash

readonly WKDIR="/cluster2/home/futing/Project/panCancer/MB"
cd "${WKDIR}" || exit 1
source activate HiC

parallel_execute() {
    local gse="$1"
    local cell="$2"
    local enzyme="$3"
    local stage="$4"

    local log_dir="${WKDIR}/${gse}/${cell}/debug"
    mkdir -p "${log_dir}" || {
        echo "Error: Failed to create log directory ${log_dir}" >&2
        return 1
    }

    local log_file="${log_dir}/${cell}-$(date +%Y%m%d).log"

    {
        echo "Starting ${cell} at $(date)"

        # 检查输入文件是否存在
        if [[ ! -e "${WKDIR}/${gse}/${cell}/fastq/"*.fastq.gz ]]; then
            echo "Error: No FASTQ files found in ${WKDIR}/${gse}/${cell}/fastq/" >&2
            return 1
        fi

        # 构建参数数组
        local args=(
            "-d" "${WKDIR}/${gse}/${cell}"
            "-e" "${enzyme}"
        )

        # 如果 stage 是有效的 Juicer 阶段，则添加 -S 参数
        if [[ -n "${stage}" && \
              "${stage}" =~ ^(merge|dedup|final|postproc|early)$ ]]; then
            args+=("-S" "${stage}")
        else
            echo "Warning: Invalid stage '${stage}'. Skipping -S parameter." >&2
        fi

        # 执行 juicer2.sh，确保参数分开传递
        echo "Running: juicer2.sh ${args[@]}"
        sh "/cluster2/home/futing/Project/panCancer/scripts/juicer2.sh" "${args[@]}"

        echo "Finished ${cell} at $(date)"
    } >> "${log_file}" 2>&1
}

export -f parallel_execute
export WKDIR
readonly PARALLEL_JOBS=6

parallel -j "${PARALLEL_JOBS}" --colsep '\t' --progress --eta \
    "parallel_execute {1} {2} {3} {4}" :::: "${WKDIR}/meta/MB_meta.txt"
