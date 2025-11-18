#!/bin/bash
#SBATCH -p gpu
#SBATCH --array=1-13%6
#SBATCH -J predictSV
#SBATCH --cpus-per-task=15
#SBATCH -o /cluster2/home/futing/Project/panCancer/Analysis/SV/debug/SV-%A_%a.log

scripts=/cluster2/home/futing/Project/panCancer/scripts/SVv2_single.sh
input=/cluster2/home/futing/Project/panCancer/Analysis/SV/SV_unrun1112.txt

line=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$input")
read cancer gse cell <<< "$line"

bash "$scripts" "$cancer" "$gse" "$cell"


# source /cluster2/home/futing/miniforge3/etc/profile.d/conda.sh
# conda activate /cluster2/home/futing/miniforge3/envs/eagleC


# parallel -j 9 --colsep '\t' \
# 'sbatch /cluster2/home/futing/Project/panCancer/scripts/SV_single.sh {1} {2} {3}' \
# ::: $(cat /cluster2/home/futing/Project/panCancer/check/hic/mcool1018p1.txt)



# samples=( $(cat sample_list.txt) )

# # 并行上限
# max_jobs=6

# for s in "${samples[@]}"; do
#     # 检查当前用户正在运行的作业数（状态为 R 或 PD）
#     while (( $(squeue -u $USER | grep -E ' R | PD ' | wc -l) >= max_jobs )); do
#         echo "当前已有 $max_jobs 个任务在运行，等待中..."
#         sleep 60   # 每隔 60 秒再检查一次
#     done

#     # 提交任务
#     echo "Submitting job for $s"
#     sbatch run_script.sh "$s"
# done

