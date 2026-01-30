#!/bin/bash

# ========== 配置参数 ==========
metafile=/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/00meta/RNAcancerlist_se.txt
script=/cluster2/home/futing/pipeline/RNA/rna_se_v2.sh
max_jobs=6  # 最多同时运行的任务数

# SLURM资源配置
CPUS=15
TIME="72:00:00"

# ========== 主程序 ==========
echo "=== Cancer RNA-seq 批量提交系统 ==="
echo "Meta文件: ${metafile}"
echo "分析脚本: ${script}"
echo "最大并发数: ${max_jobs}"
echo ""

# 获取唯一的cancer列表
mapfile -t cancers < ${metafile}
echo "总共需要处理 ${#cancers[@]} 个cancer类型:"
printf '  - %s\n' "${cancers[@]}"
echo ""

# 函数: 获取当前运行中的任务数
get_running_jobs() {
    # 方法1: 使用统一的job-name
    # squeue -u $USER --name=rna_cancer --state=RUNNING --noheader | wc -l
    
    # 方法2: 如果想保留cancer作为job-name，可以统计所有已提交job的运行数
    local running=0
    for jid in "${job_ids[@]}"; do
        if squeue -j ${jid} --state=RUNNING --noheader 2>/dev/null | grep -q .; then
            ((running++))
        fi
    done
    echo ${running}
}

# 数组保存已提交的job IDs
declare -a job_ids=()

# 提交所有任务
submitted=0
nodes=(node1 node4 node5)
n_nodes=${#nodes[@]}
for cancer in "${cancers[@]}"; do
    # 等待直到运行任务数少于最大值
    while true; do
        current=$(get_running_jobs)
        if [ ${current} -lt ${max_jobs} ]; then
            break
        fi
        echo "[$(date '+%H:%M:%S')] 当前有 ${current} 个任务运行中，等待空位..."
        sleep 5
    done
    
    # 设置目录
    dir=/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/${cancer}/
    log_dir=${dir}/debug
    mkdir -p ${log_dir}
    # ===== 核心：轮流选节点 =====
    node="${nodes[$((submitted % n_nodes))]}"

    # 提交任务并获取job ID
    job_output=$(sbatch --job-name=${cancer} \
	       --nodelist="${node}" \
           --output=${log_dir}/${cancer}_%j.log \
           --cpus-per-task=${CPUS} \
           --time=${TIME} \
           --wrap="echo 'Cancer: ${cancer}'; echo 'Directory: ${dir}'; echo 'Start: \$(date)'; bash ${script} ${dir}; echo 'End: \$(date)'")
    
    job_id=$(echo ${job_output} | awk '{print $4}')
    job_ids+=("${job_id}")
    
    ((submitted++))
    current=$(get_running_jobs)
    echo "[$(date '+%H:%M:%S')] ✓ 已提交 ${cancer} (JobID: ${job_id}) - 进度: ${submitted}/${#cancers[@]} - 运行中: ${current}"
    
    # 短暂延迟，确保任务状态更新
    sleep 2
done

echo ""
echo "=== 提交完成 ==="
echo "总共提交: ${submitted} 个任务"
echo "Job IDs: ${job_ids[*]}"
echo ""
echo "监控命令:"
echo "  查看队列: squeue -u $USER --name=rna_cancer"
echo "  实时监控: watch -n 5 'squeue -u $USER --name=rna_cancer'"
echo "  取消所有: scancel ${job_ids[*]}"
echo ""
echo "查看特定cancer日志:"
for cancer in "${cancers[@]}"; do
    echo "  ${cancer}: tail -f ${dir}/debug/${cancer}_*.log"
done