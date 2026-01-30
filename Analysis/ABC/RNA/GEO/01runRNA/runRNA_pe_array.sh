#!/bin/bash
#SBATCH -p normal
#SBATCH --job-name=RNA_Cancer
#SBATCH --output=/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/logs/array_%A_%a.log
#SBATCH --cpus-per-task=15
#SBATCH --time=72:00:00
#SBATCH --nodelist=node1,node5
#SBATCH --array=0-6%6  # 注意：这里的 19 需要根据 metafile 的行数修改，%6 是最大并发

# ========== 1. 配置参数 ==========
metafile=/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/00meta/RNAcancerlist_se.txt
script=/cluster2/home/futing/pipeline/RNA/rna_pe_v2.sh
base_dir=/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO

# ========== 2. 解析当前任务对应的 Cancer 类型 ==========
# 读取 metafile 的第 $SLURM_ARRAY_TASK_ID + 1 行
mapfile -t cancers < ${metafile}
cancer=${cancers[$SLURM_ARRAY_TASK_ID]}

if [ -z "$cancer" ]; then
    echo "Error: No cancer type found for Index $SLURM_ARRAY_TASK_ID"
    exit 1
fi

# ========== 3. 准备环境与执行 ==========
dir="${base_dir}/${cancer}"
log_dir="${dir}/debug"
mkdir -p "${log_dir}"

echo "Task ID: $SLURM_ARRAY_TASK_ID"
echo "Cancer: $cancer"
echo "Node: $HOSTNAME"
echo "Start: $(date)"

# 执行分析脚本
bash "${script}" "${dir}"

echo "End: $(date)"