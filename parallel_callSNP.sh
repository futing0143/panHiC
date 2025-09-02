#!/bin/bash
#SBATCH --cpus-per-task=20
#SBATCH --output=/cluster2/home/futing/Project/HiCQTL/GVCF-%j.log
#SBATCH -J "GVCF"
ulimit -s unlimited
ulimit -l unlimited
source activate /cluster/home/futing/miniforge-pypy3/envs/HiC
# 全局变量
debugdir="/cluster2/home/futing/Project/HiCQTL/CRC_gvcf"
mkdir -p "$debugdir/debug"

# 定义并行执行函数
parallel_execute() {
	local cell=$1
    
    # 为每个任务创建单独的日志文件
    local log_file="$debugdir/debug/${cell}-$(date +%Y%m%d_%H%M%S).log"
    
    echo "Starting $cell at $(date)" > "$log_file"
    sh "/cluster2/home/futing/Project/HiCQTL/callSNP.sh" \
       "/cluster2/home/futing/Project/HiCQTL/CRC/${cell}/${cell}.sorted.bam" >> "$log_file" 2>&1
    echo "Finished $cell at $(date)" >> "$log_file"
}

# 导出函数和环境变量以便parallel使用
export -f parallel_execute
export debugdir

# 设置并行度
PARALLEL_JOBS=4

# 使用:::传递参数
parallel -j $PARALLEL_JOBS --colsep ' ' --progress --eta \
  "parallel_execute {1}" :::: "/cluster2/home/futing/Project/HiCQTL/CRCdone.txt"