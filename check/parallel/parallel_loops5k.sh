#!/bin/bash
#SBATCH -p gpu
#SBATCH --cpus-per-task=24
#SBATCH --nodelist=node2
#SBATCH --output=/cluster2/home/futing/Project/panCancer/check/loops5k_parallel-%j.log
#SBATCH -J "loops5k_parallel"

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
    
    local log_file="${log_dir}/${tools}_${cell}-$(date +%Y%m%d_%H%M%S).log"
    
    # 使用代码块统一重定向
    {
        echo "Starting ${cell} at $(date)"
        
        case "${tools}" in
            "cooltools")
                sh "/cluster2/home/futing/Project/panCancer/scripts/dots_single.sh" \
                    "${wkdir}/${cancer}/${gse}/${cell}" 5000
                ;;
            "fithic")
                # echo "Skipping fithic by design"
				sh "/cluster2/home/futing/Project/panCancer/scripts/fithic_single.sh" \
                    "${wkdir}/${cancer}/${gse}/${cell}" 5000 "" 0.2
                ;;
            *)
                sh "/cluster2/home/futing/Project/panCancer/scripts/${tools}_single.sh" \
                    "${wkdir}/${cancer}/${gse}/${cell}"
                ;;
        esac
        
        echo "Finished ${cell} at $(date)"
    } >> "${log_file}" 2>&1
}

export -f parallel_execute
export WKDIR
readonly PARALLEL_JOBS=10

# 执行并行任务
parallel -j "${PARALLEL_JOBS}" --colsep '\t' --progress --eta \
	--tmpdir /cluster2/home/futing/Project/panCancer/check/debug \
    "parallel_execute {1} {2} {3} {4} '${WKDIR}'" :::: "${WKDIR}/check/unpost/loops/loops5k_1110.txt"

date