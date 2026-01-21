#!/bin/bash

# ========== 配置参数 ==========
metafile=/cluster2/home/futing/Project/panCancer/Analysis/ABC/ATAC/GEO/new/ATACtest.tsv
script=/cluster2/home/futing/pipeline/newATAC/ATAC_v4.sh
max_jobs=6  # 最多同时运行的任务数

# SLURM资源配置
CPUS=15
TIME="72:00:00"

# ========== 主程序 ==========
echo "=== Cancer ATAC-seq 批量提交系统 ==="
echo "Meta文件: ${metafile}"
echo "分析脚本: ${script}"
echo "最大并发数: ${max_jobs}"
echo ""

# 读取metafile，提取cancer、gse、ID三列
# 假设文件格式：第1列=cancer, 第5列=gse, 第10列=ID, 第8列=gsm
declare -a cancers=()
declare -a gses=()
declare -a ids=()

while IFS=$'\t' read -r cancer gse id; do
    cancers+=("${cancer}")
    gses+=("${gse}")
    ids+=("${id}")
done < <(tail -n +2 ${metafile} | cut -f1,7,10 | sort -u)

echo "总共需要处理 ${#cancers[@]} 个数据集:"
for i in "${!cancers[@]}"; do
    echo "  - ${cancers[$i]} / ${gses[$i]} / ${ids[$i]}"
done
echo ""

# 函数: 获取当前运行中的任务数
get_running_jobs() {
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
for i in "${!cancers[@]}"; do
    cancer="${cancers[$i]}"
    gse="${gses[$i]}"
    id="${ids[$i]}"
    
    # 等待直到运行任务数少于最大值
    while true; do
        current=$(get_running_jobs)
        if [ ${current} -lt ${max_jobs} ]; then
            break
        fi
        echo "[$(date '+%H:%M:%S')] 当前有 ${current} 个任务运行中，等待空位..."
        sleep 5
    done
    
    # 设置目录 - 每个cancer/gse组合有独立目录
    dir=/cluster2/home/futing/Project/panCancer/Analysis/ABC/ATAC/GEO/${cancer}/${gse}/
    log_dir=${dir}/debug
    mkdir -p ${log_dir}
    
    # 提交任务并获取job ID
    job_name="${ID}"
    job_output=$(sbatch --job-name=${job_name} \
		   --partition=gpu \
           --output=${log_dir}/${ID}_%j.log \
           --cpus-per-task=${CPUS} \
           --time=${TIME} \
           --wrap="echo 'Cancer: ${cancer}'; echo 'GSE: ${gse}'; echo 'ID: ${id}'; echo 'Directory: ${dir}'; echo 'Start: \$(date)'; bash ${script} -d ${dir} -n ${id} -s ${dir}/srr.txt; echo 'End: \$(date)'")
    
    job_id=$(echo ${job_output} | awk '{print $4}')
    job_ids+=("${job_id}")
    
    ((submitted++))
    current=$(get_running_jobs)
    echo "[$(date '+%H:%M:%S')] ✓ 已提交 ${cancer}/${gse} (ID: ${id}, JobID: ${job_id}) - 进度: ${submitted}/${#cancers[@]} - 运行中: ${current}"
    
    # 短暂延迟，确保任务状态更新
    sleep 2
done

echo ""
echo "=== 提交完成 ==="
echo "总共提交: ${submitted} 个任务"
echo "Job IDs: ${job_ids[*]}"
echo ""
echo "监控命令:"
echo "  查看队列: squeue -u $USER"
echo "  实时监控: watch -n 5 'squeue -u $USER'"
echo "  取消所有: scancel ${job_ids[*]}"
echo ""
echo "查看日志:"
for i in "${!cancers[@]}"; do
    cancer="${cancers[$i]}"
    gse="${gses[$i]}"
    dir=/cluster2/home/futing/Project/panCancer/Analysis/ABC/ATAC/GEO/${cancer}/${gse}/
    echo "  ${cancer}/${gse}: tail -f ${dir}/debug/${ID}_*.log"
done
