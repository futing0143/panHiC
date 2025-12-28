#!/bin/bash
#SBATCH -p gpu
#SBATCH --array=1-17%3
#SBATCH --nodelist=node3
#SBATCH -J ZoomCool
#SBATCH --cpus-per-task=5
#SBATCH --distribution=cyclic
#SBATCH -o /cluster2/home/futing/Project/panCancer/CRC/GSE207951/debug/ZoomCool-%A_%a.log


scripts=/cluster2/home/futing/Project/panCancer/scripts/mcool_trans_reso.sh
input=/cluster2/home/futing/Project/panCancer/CRC/GSE207951/CRC.txt
actual_line=$((16 + SLURM_ARRAY_TASK_ID))
cell=$(sed -n "${actual_line}p" "$input")
bash "$scripts" "$cell"
# line=$(sed -n "${SLURM_ARRAY_TASK_ID}p" <(sed -n '17,33p' "$input"))
# read cell <<< "$line"

#---------------
# cell=A002C010

# bash /cluster2/home/futing/Project/panCancer/scripts/mcool2cool_single.sh \
# 	5000 "/cluster2/home/futing/Project/panCancer/CRC/GSE207951/${cell}/cool/${cell}.mcool" \
# 	/cluster2/home/futing/Project/panCancer/CRC/GSE207951/${cell}/cool/

# bash "$scripts" "/cluster2/home/futing/Project/panCancer/CRC/GSE207951/${cell}"


# scripts=/cluster2/home/futing/Project/panCancer/scripts/SV_single.sh
# IFS=$'\t'
# while read -r cancer gse cell;do
# 	debug_dir="/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}/debug"
# 	timestamp=$(date +%Y%m%d_%H%M%S)
#     logfile="${debug_dir}/SV_${timestamp}.log"
    
#     echo "----- Processing: bash $scripts $cancer $gse $cell"
#     echo "Logfile: $logfile"

# 	bash "$scripts" "$cancer" "$gse" "$cell" > "$logfile" 2>&1
#  done < <(sed -n '46,51p' /cluster2/home/futing/Project/panCancer/Analysis/SV/SV_unrun1206.txt)
