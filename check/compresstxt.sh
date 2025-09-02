#!/bin/bash
#SBATCH -p normal
#SBATCH --cpus-per-task=10
#SBATCH --nodelist=node1
#SBATCH --output=/cluster2/home/futing/Project/panCancer/check/gzip-%j.log
#SBATCH -J "gzip"
ulimit -s unlimited
ulimit -l unlimited

# 定义包含SAM文件的根目录
source activate /cluster2/home/futing/miniforge3/envs/hic
readonly WKDIR="/cluster2/home/futing/Project/panCancer/check"
cd "${WKDIR}" || exit 1

parallel_execute() {
    local cancer="$1"
    local gse="$2"
    local cell="$3"
   
    # 确保日志目录存在
    local log_dir="${WKDIR}/debug"
    mkdir -p "${log_dir}" || {
        echo "Error: Failed to create log directory ${log_dir}" >&2
        return 1
    }
    
    local log_file="${log_dir}/${cancer}_${gse}_${cell}-$(date +%Y%m%d_%H%M%S).log"
    
    # 使用代码块统一重定向
    {
		echo -e "Processing ${cancer}/${gse}/${cell}...\n"
		root_directory=/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}
		find "$root_directory" -type f -name "*txt" -print0 | while IFS= read -r -d '' file
		do
			# 去除文件名末尾的回车符
			file="${file%$'\r'}"
			bgzip $file
			echo "compress gzip: $file"
		done
    } >> "${log_file}" 2>&1
}

export -f parallel_execute
export WKDIR
readonly PARALLEL_JOBS=5

# 执行并行任务
parallel -j "${PARALLEL_JOBS}" --colsep '\t' --progress --eta \
    "parallel_execute {1} {2} {3}" :::: "${WKDIR}/gzip_0827.txt"

date