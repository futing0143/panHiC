#!/bin/bash
#SBATCH -p gpu
#SBATCH --cpus-per-task=45
#SBATCH --nodelist=node2
#SBATCH --output=/cluster2/home/futing/Project/panCancer/Analysis/SV/SV_parallel-%j.log
#SBATCH -J "SVp3"
ulimit -s unlimited
ulimit -l unlimited

date
readonly WKDIR="/cluster2/home/futing/Project/panCancer/"
cd "${WKDIR}" || exit 1
source activate /cluster2/home/futing/miniforge3/envs/juicer

# 定义并行执行函数
parallel_execute() {
	local cancer="$1"
    local gse="$2"
    local cell="$3"
    local wkdir="$4"  # 显式传递的工作目录
    tools="SV"
    # 确保日志目录存在
    local log_dir="${wkdir}/${cancer}/${gse}/${cell}/debug"
    mkdir -p "${log_dir}" || {
        echo "Error: Failed to create log directory ${log_dir}" >&2
        return 1
    }
    
    local log_file="${log_dir}/${tools}_${cell}-$(date +%Y%m%d).log"
    
    # 使用代码块统一重定向
    {
        echo "Starting ${cell} at $(date)"
        
		sh "/cluster2/home/futing/Project/panCancer/scripts/SV_single.sh" \
			"${cancer}" "${gse}" "${cell}"
        echo "Finished ${cell} at $(date)"
    } >> "${log_file}" 2>&1
}

export -f parallel_execute
export WKDIR
readonly PARALLEL_JOBS=3

# 执行并行任务
parallel -j "${PARALLEL_JOBS}" --colsep '\t' --progress --eta \
    "parallel_execute {1} {2} {3} '${WKDIR}'" :::: "${WKDIR}/check/hic/mcool1018p3.txt"

date