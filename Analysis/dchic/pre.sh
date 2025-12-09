#!/bin/bash
#SBATCH -p gpu
#SBATCH --cpus-per-task=24
#SBATCH --output=/cluster2/home/futing/Project/panCancer/Analysis/dchic/convert-%j.log
#SBATCH -J "convert"
ulimit -s unlimited
ulimit -l unlimited

date
readonly WKDIR="/cluster2/home/futing/Project/panCancer/"
cd "${WKDIR}" || exit 1
source activate /cluster2/home/futing/miniforge3/envs/juicer

meta=/cluster2/home/futing/Project/panCancer/Analysis/dchic/meta/preundone1112.txt
# meta=/cluster2/home/futing/Project/panCancer/Analysis/dchic/meta/p2.txt


parallel_execute() {
	local cancer="$1"
    local gse="$2"
    local cell="$3"
    local wkdir="$4"  # 显式传递的工作目录
    
    # 确保日志目录存在
    local log_dir="${wkdir}/${cancer}/${gse}/${cell}/debug"
    mkdir -p "${log_dir}" || {
        echo "Error: Failed to create log directory ${log_dir}" >&2
        return 1
    }
    
    local log_file="${log_dir}/dchic_${cell}-$(date +%Y%m%d).log"
    
    # 使用代码块统一重定向
    {
        echo "Starting ${cell} at $(date)"
		cd "${wkdir}/${cancer}/${gse}/${cell}/cool" || exit 1
		file=/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}/cool/${cell}_100000.cool
		genomeFile=/cluster2/home/futing/Project/panCancer/Analysis/dchic/meta/hg38_23chr.genome
		if [ ! -f "${file}" ]; then
            echo "File not found: ${file}"
            exit 1
        fi
        source activate /cluster2/home/futing/miniforge3/envs/dchic

		python /cluster2/home/futing/software/dcHiC-master/utility/preprocess.py \
			-input cool -file ${file} \
			-genomeFile ${genomeFile} -res 100000 -prefix ${cell}
        echo "Finished ${cell} at $(date)"
    } >> "${log_file}" 2>&1
}

export -f parallel_execute
export WKDIR
readonly PARALLEL_JOBS=6

# 执行并行任务
parallel -j "${PARALLEL_JOBS}" --colsep '\t' --progress --eta \
    "parallel_execute {1} {2} {3} '${WKDIR}'" :::: "${meta}"

date
