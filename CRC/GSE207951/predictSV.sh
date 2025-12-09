#!/bin/bash
#SBATCH -p gpu
#SBATCH --array=1-33%6
#SBATCH -J ZoomCool
#SBATCH --cpus-per-task=5
#SBATCH --distribution=cyclic
#SBATCH -o /cluster2/home/futing/Project/panCancer/CRC/GSE207951/debug/ZoomCool-%A_%a.log


scripts=/cluster2/home/futing/Project/panCancer/scripts/SV_v1.2_single.sh
# input=/cluster2/home/futing/Project/panCancer/CRC/GSE207951/CRC.txt
# line=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$input")
# read cell <<< "$line"


IFS=$'\t'
while read -r cell;do
	cancer=CRC
	gse=GSE207951
	debug_dir="/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}/debug"
	timestamp=$(date +%Y%m%d_%H%M%S)
    logfile="${debug_dir}/SV_${timestamp}.log"
    
    echo "----- Processing: bash $scripts $cancer $gse $cell"
    echo "Logfile: $logfile"

	bash "$scripts" "/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}" \
	"3reso" > "$logfile" 2>&1
# done < <(sed -n '1,8p' /cluster2/home/futing/Project/panCancer/CRC/GSE207951/CRC.txt)
# done < <(sed -n '9,16p' /cluster2/home/futing/Project/panCancer/CRC/GSE207951/CRC.txt)
# done < <(sed -n '17,24p' /cluster2/home/futing/Project/panCancer/CRC/GSE207951/CRC.txt)
done < <(sed -n '25,33p' /cluster2/home/futing/Project/panCancer/CRC/GSE207951/CRC.txt)