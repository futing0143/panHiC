#!/bin/bash
#SBATCH -J m2c
#SBATCH --output=/cluster2/home/futing/Project/panCancer/PRAD/GSE249494_%j.log
#SBATCH --nodelist=node3
#SBATCH -p gpu
#SBATCH --cpus-per-task=20

cd /cluster2/home/futing/Project/panCancer/PRAD/GSE249494
source activate /cluster2/home/futing/miniforge3/envs/juicer
mkdir -p debug

parallel_execute() {
    local file="$1"

    
    # 确保日志目录存在
    local log_dir="/cluster2/home/futing/Project/panCancer/PRAD/GSE249494/debug"
    mkdir -p "${log_dir}" || {
        echo "Error: Failed to create log directory ${log_dir}" >&2
        return 1
    }
    name=$(basename ${file} | cut -d'_' -f2)
    local log_file="${log_dir}/${name}-$(date +%Y%m%d).log"
    
    # 使用代码块统一重定向
    {
        echo "Starting ${name} at $(date)"
		bash /cluster2/home/futing/Project/panCancer/PRAD/matrix2cool.sh ${file}        
        echo "Finished ${name} at $(date)"
    } >> "${log_file}" 2>&1
}

export -f parallel_execute
readonly PARALLEL_JOBS=6

# 执行并行任务
parallel -j "${PARALLEL_JOBS}" --colsep '\t' --progress --eta \
    "parallel_execute {1}" :::: "/cluster2/home/futing/Project/panCancer/PRAD/GSE249494/list1013.txt"
