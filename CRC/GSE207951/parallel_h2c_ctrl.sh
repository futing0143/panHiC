#!/bin/bash
#SBATCH -p gpu
#SBATCH --array=1-4%6
#SBATCH -J CRCctrl
#SBATCH --cpus-per-task=10
#SBATCH --distribution=cyclic
#SBATCH --ntasks-per-node=2
#SBATCH -o /cluster2/home/futing/Project/panCancer/CRC/GSE207951/debug/CRCctrl-%A_%a.log

# scripts="/cluster2/home/futing/Project/panCancer/scripts/juicerv1_p.sh"
# input=/cluster2/home/futing/Project/panCancer/CRC/GSE207951/CRC_ctrl.txt

# line=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$input")
# read cell <<< "$line"

# bash "$scripts" -d "/cluster2/home/futing/Project/panCancer/CRC/GSE207951/${cell}/" -e mHiC



# --- rerun err file

scripts="/cluster2/home/futing/Project/panCancer/scripts/juicerv1.3.sh"
input=/cluster2/home/futing/Project/panCancer/CRC/GSE207951/CRC_ctrlerr.txt

# line=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$input")
# read cell <<< "$line"

bash "$scripts" -d "/cluster2/home/futing/Project/panCancer/CRC/GSE207951/A002C001/" -e mHiC


