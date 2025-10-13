#!/bin/bash
#SBATCH --cpus-per-task=10
#SBATCH --nodelist=node1
#SBATCH --output=/cluster2/home/futing/Project/panCancer/check/debug/coolerr-%j.log
#SBATCH -J "coolerr"

source activate /cluster2/home/futing/miniforge3/envs/juicer
# grep 'PC' /cluster2/home/futing/Project/panCancer/check/post/unpost_1012nig.txt | cut -f1-3 > /cluster2/home/futing/Project/panCancer/check/post/PCundone1012nig.txt
# >"/cluster2/home/futing/Project/panCancer/check/post/PCundone1012nig.txt"
# awk 'BEGIN{FS=OFS="\t"}{if ($4=="PC") print $1,$2,$3}' /cluster2/home/futing/Project/panCancer/check/post/unpost_1012nig.txt \
# 	>> /cluster2/home/futing/Project/panCancer/check/post/PCundone1012nig.txt

IFS=$"\t"
while read -r cancer gse cell;do
	echo "Processing ${cancer} ${gse} ${cell}"
	cd /cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}

	resolutions=(1000 5000 10000 25000 50000 100000 250000 500000 1000000 2500000)
	for resolution in "${resolutions[@]}"; do
		echo "Balancing at resolution $resolution..."
		cooler balance ./cool/"${cell}".mcool::resolutions/"${resolution}"
	done
	
	for resolution in "${resolutions[@]}"; do
        echo "Processing resolution $resolution..."
        sh /cluster2/home/futing/Project/panCancer/scripts/mcool2cool_single.sh \
            "$resolution" ./cool/"${cell}".mcool ./cool
    done
    
done < "/cluster2/home/futing/Project/panCancer/check/post/coolundone1012nig.txt"