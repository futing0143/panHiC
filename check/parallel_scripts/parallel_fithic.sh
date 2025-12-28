#!/bin/bash
#SBATCH -p normal
#SBATCH --cpus-per-task=20
#SBATCH --nodelist=node4
#SBATCH --output=/cluster2/home/futing/Project/panCancer/check/dots_parallel-%j.log
#SBATCH -J "dots"
ulimit -s unlimited
ulimit -l unlimited

date
readonly WKDIR="/cluster2/home/futing/Project/panCancer/"
cd "${WKDIR}" || {
    echo "Error: Failed to change directory to ${WKDIR}" >&2
    exit 1
}
source activate /cluster2/home/futing/miniforge3/envs/juicer

# 定义并行执行函数
parallel_execute() {
	local cancer="$1"
    local gse="$2"
    local cell="$3"
	local tools="$4"
    local wkdir="$5"  # 显式传递的工作目录
    
    # 确保日志目录存在
    local log_dir="${wkdir}/${cancer}/${gse}/${cell}/debug"
    mkdir -p "${log_dir}" || {
        echo "Error: Failed to create log directory ${log_dir}" >&2
        return 1
    }
    
    # 使用更精确的时间戳避免日志文件名冲突
    local log_file="${log_dir}/${tools}_${cell}-$(date +%Y%m%d_%H%M%S).log"
    
    # 使用代码块统一重定向
    {
        echo "Starting ${cell} at $(date)"
        
		# sh "/cluster2/home/futing/Project/panCancer/scripts/insul_single.sh" \
		# 	"${wkdir}/${cancer}/${gse}/${cell}" 50000 800000
		# sh "/cluster2/home/futing/Project/panCancer/scripts/dots_single.sh" \
		# 	"${wkdir}/${cancer}/${gse}/${cell}"
		sh "/cluster2/home/futing/Project/panCancer/scripts/fithic_single.sh" \
			"${wkdir}/${cancer}/${gse}/${cell}" 10000 "" 0.25
        echo "Finished ${cell} at $(date)"
    } >> "${log_file}" 2>&1
}

export -f parallel_execute
export WKDIR
readonly PARALLEL_JOBS=6

# 执行并行任务
parallel -j "${PARALLEL_JOBS}" --colsep '\t' \
	--tmpdir="/cluster2/home/futing/Project/panCancer/check/debug" \
    "parallel_execute {1} {2} {3} {4} '${WKDIR}'" :::: "${WKDIR}/check/unpost/loops/fithic_0.25.txt"

date