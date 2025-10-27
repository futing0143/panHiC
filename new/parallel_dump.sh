#!/bin/bash
#SBATCH -p gpu
#SBATCH -t 8000
#SBATCH --cpus-per-task=20
#SBATCH --output=/cluster2/home/futing/Project/panCancer/new/dump1026-%j.log
#SBATCH -J "dump"

date
readonly WKDIR="/cluster2/home/futing/Project/panCancer/new"
cd "${WKDIR}" || exit 1
source activate /cluster2/home/futing/miniforge3/envs/RNA

# 定义并行执行函数
parallel_execute() {
    local name="$1"
    
    # 确保日志目录存在
    local log_dir="${WKDIR}/debug"
    mkdir -p "${log_dir}" || {
        echo "Error: Failed to create log directory ${log_dir}" >&2
        return 1
    }
    
    local log_file="${log_dir}/${name}-$(date +%Y%m%d_%H%M%S).log"
    
    # 使用代码块统一重定向
    {
        echo "Starting ${cell} at $(date)"
		source activate /cluster2/home/futing/miniforge3/envs/RNA
		OS_INFO=$(uname -a)
		echo "系统信息: $OS_INFO"

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
    "parallel_execute {1}" :::: "${WKDIR}/dumperr.txt"

date