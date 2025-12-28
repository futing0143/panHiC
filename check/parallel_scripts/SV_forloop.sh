#!/bin/bash
#SBATCH -p gpu
#SBATCH --array=1-133%6
#SBATCH -J predictSV
#SBATCH --cpus-per-task=15
#SBATCH -o /cluster2/home/futing/Project/panCancer/Analysis/SV/debug/SV-%A_%a.log

scripts=/cluster2/home/futing/Project/panCancer/scripts/SV_v1.2_single.sh
IFS=$'\t'
while read -r cancer gse cell;do
	debug_dir="/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}/debug"
	timestamp=$(date +%Y%m%d_%H%M%S)
    logfile="${debug_dir}/SV_${timestamp}.log"
    
    echo "----- Processing: bash $scripts $cancer $gse $cell"
    echo "Logfile: $logfile"

	bash "$scripts" "/cluster2/home/futing/Project/panCancer/$cancer/$gse/$cell" > "$logfile" 2>&1
done < <(sed -n '21,25p' /cluster2/home/futing/Project/panCancer/Analysis/SV/SV_unrun1217.txt)
# done < "/cluster2/home/futing/Project/panCancer/Analysis/SV/SV_post1027.txt"
# done < <(sed -n '38,53p' '/cluster2/home/futing/Project/panCancer/Analysis/SV/SV_unrun1210aft.txt')
# done < <(sed -n '17,37p' '/cluster2/home/futing/Project/panCancer/Analysis/SV/SV_unrun1210aft.txt')

# done < "/cluster2/home/futing/Project/panCancer/Analysis/SV/SV_unrun1107p1.txt"
# done < <(head -n16 '/cluster2/home/futing/Project/panCancer/Analysis/SV/SV_unrun1210aft.txt')

scripts=/cluster2/home/futing/Project/panCancer/scripts/SV_single.sh
IFS=$'\t'
while read -r cancer gse cell;do
	debug_dir="/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}/debug"
	timestamp=$(date +%Y%m%d_%H%M%S)
    logfile="${debug_dir}/SV_${timestamp}.txt"
    
    echo "----- Processing: bash $scripts $cancer $gse $cell"
    echo "Logfile: $logfile"

	bash "$scripts" "$cancer" "$gse" "$cell" > "$logfile" 2>&1
done < <(sed -n '35,39p' /cluster2/home/futing/Project/panCancer/Analysis/SV/SV_unrun1120p2.txt | tac)

scripts=/cluster2/home/futing/Project/panCancer/scripts/SV_single.sh
IFS=$'\t'
while read -r cancer gse cell;do
	debug_dir="/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}/debug"
	timestamp=$(date +%Y%m%d_%H%M%S)
    logfile="${debug_dir}/SV_${timestamp}.txt"
    
    echo "----- Processing: bash $scripts $cancer $gse $cell"
    echo "Logfile: $logfile"

	bash "$scripts" "$cancer" "$gse" "$cell" > "$logfile" 2>&1
done < <(sed -n '31,34p' /cluster2/home/futing/Project/panCancer/Analysis/SV/SV_unrun1120p2.txt | tac)

scripts=/cluster2/home/futing/Project/panCancer/scripts/SV_single.sh
IFS=$'\t'
while read -r cancer gse cell;do
	debug_dir="/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}/debug"
	timestamp=$(date +%Y%m%d_%H%M%S)
    logfile="${debug_dir}/SV_${timestamp}.txt"
    
    echo "----- Processing: bash $scripts $cancer $gse $cell"
    echo "Logfile: $logfile"

	bash "$scripts" "$cancer" "$gse" "$cell" > "$logfile" 2>&1
done < <(sed -n '29,30p' /cluster2/home/futing/Project/panCancer/Analysis/SV/SV_unrun1120p2.txt | tac)


scripts=/cluster2/home/futing/Project/panCancer/scripts/SV_single.sh
IFS=$'\t'
while read -r cancer gse cell;do
	debug_dir="/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}/debug"
	timestamp=$(date +%Y%m%d_%H%M%S)
    logfile="${debug_dir}/SV_${timestamp}.log"
    
    echo "----- Processing: bash $scripts $cancer $gse $cell"
    echo "Logfile: $logfile"

	bash "$scripts" "$cancer" "$gse" "$cell" > "$logfile" 2>&1
# done < <(sed -n '1,5p' /cluster2/home/futing/Project/panCancer/Analysis/SV/SV_unrun1207.txt)
done < <(sed -n '6,9p' /cluster2/home/futing/Project/panCancer/Analysis/SV/SV_unrun1207.txt)
# done < <(sed -n '46,51p' /cluster2/home/futing/Project/panCancer/Analysis/SV/SV_unrun1206.txt)
# done < <(sed -n '31,40p' /cluster2/home/futing/Project/panCancer/Analysis/SV/SV_unrun1206.txt)
# done < <(sed -n '15,30p' /cluster2/home/futing/Project/panCancer/Analysis/SV/SV_unrun1206.txt)
# done < <(sed -n '1,10p' /cluster2/home/futing/Project/panCancer/Analysis/SV/SV_unrun1206.txt)
# done < <(sed -n '11,14p' /cluster2/home/futing/Project/panCancer/Analysis/SV/SV_unrun1206.txt | head -n10)
# done < "/cluster2/home/futing/Project/panCancer/Analysis/SV/SV_post1027.txt"
# done < "/cluster2/home/futing/Project/panCancer/Analysis/SV/SV_unrun1107p1.txt"
# done < <(sed -n '21,25p' /cluster2/home/futing/Project/panCancer/Analysis/SV/SV_unrun1123.txt | tac)
# done < <(sed -n '15,20p' /cluster2/home/futing/Project/panCancer/Analysis/SV/SV_unrun1123.txt | tac)