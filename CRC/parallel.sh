#!/bin/bash

readonly WKDIR="/cluster2/home/futing/Project/panCancer/CRC"
cd "${WKDIR}" || exit 1
source activate HiC

# 定义并行执行函数
parallel_execute() {
    local gse="$1"
    local cell="$2"
    local tools="$3"
    local wkdir="$4"  # 显式传递的工作目录
    
    # 确保日志目录存在
    local log_dir="${wkdir}/${gse}/${cell}/debug"
    mkdir -p "${log_dir}" || {
        echo "Error: Failed to create log directory ${log_dir}" >&2
        return 1
    }
    
    local log_file="${log_dir}/${tools}_${cell}-$(date +%Y%m%d).log"
    
    # 使用代码块统一重定向
    {
        echo "Starting ${cell} at $(date)"
        
        case "${tools}" in
            "cooltools")
                sh "/cluster2/home/futing/Project/panCancer/scripts/dots_single.sh" \
                    "${wkdir}/${gse}/${cell}"
                ;;
            "fithic")
                echo "Skipping fithic by design"
                ;;
            *)
                sh "/cluster2/home/futing/Project/panCancer/scripts/${tools}_single.sh" \
                    "${wkdir}/${gse}/${cell}"
                ;;
        esac
        
        echo "Finished ${cell} at $(date)"
    } >> "${log_file}" 2>&1
}

export -f parallel_execute
export WKDIR
readonly PARALLEL_JOBS=6

# 执行并行任务
parallel -j "${PARALLEL_JOBS}" --colsep '\t' --progress --eta \
    "parallel_execute {1} {2} {3} '${WKDIR}'" :::: "${WKDIR}/check/check_July06.txt"
