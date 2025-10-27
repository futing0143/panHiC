#!/bin/bash
#SBATCH -p gpu
#SBATCH --cpus-per-task=15
#SBATCH --output=/cluster2/home/futing/Project/panCancer/check/post_parallel-%j.log
#SBATCH -J "PC"
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
    local tools="$4"
    local wkdir="$5"  # 显式传递的工作目录
    
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
        
		# sh "/cluster2/home/futing/Project/panCancer/scripts/insul_single.sh" \
		# 	"${wkdir}/${cancer}/${gse}/${cell}" 50000 800000
		sh "/cluster2/home/futing/Project/panCancer/scripts/PC_single.sh" \
			"${wkdir}/${cancer}/${gse}/${cell}"
        echo "Finished ${cell} at $(date)"
    } >> "${log_file}" 2>&1
}

export -f parallel_execute
export WKDIR
readonly PARALLEL_JOBS=3

# 执行并行任务
parallel -j "${PARALLEL_JOBS}" --colsep '\t' --progress --eta \
    "parallel_execute {1} {2} {3} {4} '${WKDIR}'" :::: "${WKDIR}/check/post/coolundone1012nig.txt"

date