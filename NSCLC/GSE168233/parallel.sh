#!/bin/bash

readonly WKDIR="/cluster2/home/futing/Project/panCancer/NSCLC/GSE168233"
cd "${WKDIR}" || exit 1
source activate RNA

# 定义并行执行函数
parallel_execute() {
    local name="$1"
    
    # 确保日志目录存在
    local log_dir="${WKDIR}/debug"
    mkdir -p "${log_dir}" || {
        echo "Error: Failed to create log directory ${log_dir}" >&2
        return 1
    }
    
    local log_file="${log_dir}/${name}-$(date +%Y%m%d).log"
    
    # 使用代码块统一重定向
    {
        echo "Starting ${cell} at $(date)"
		source activate RNA
        export TMPDIR=${WKDIR}/debug
		echo -e "parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip"
		parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip

        echo "Finished ${cell} at $(date)"
    } >> "${log_file}" 2>&1
}

export -f parallel_execute
export WKDIR
readonly PARALLEL_JOBS=5

# 执行并行任务
parallel -j "${PARALLEL_JOBS}" --colsep '\t' --progress --eta \
    "parallel_execute {1}" :::: "${WKDIR}/dump.txt"
