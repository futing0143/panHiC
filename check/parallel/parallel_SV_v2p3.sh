#!/bin/bash
#SBATCH -p gpu
#SBATCH --array=1-133%6
#SBATCH -J predictSV
#SBATCH --cpus-per-task=15
#SBATCH -o /cluster2/home/futing/Project/panCancer/Analysis/SV/debug/SV-%A_%a.log

scripts=/cluster2/home/futing/Project/panCancer/scripts/SVv2_single.sh
IFS=$'\t'
while read -r cancer gse cell;do
	debug_dir="/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}/debug"
	timestamp=$(date +%Y%m%d_%H%M%S)
    logfile="${debug_dir}/SV_${timestamp}.txt"
    
    echo "----- Processing: bash $scripts $cancer $gse $cell"
    echo "Logfile: $logfile"

	bash "$scripts" "$cancer" "$gse" "$cell" > "$logfile" 2>&1
	# done < "/cluster2/home/futing/Project/panCancer/Analysis/SV/SV_post1027.txt"
done < "/cluster2/home/futing/Project/panCancer/Analysis/SV/SV_unrun1107p1.txt"
