#!/bin/bash
#SBATCH -p normal
#SBATCH --cpus-per-task=15
#SBATCH --output=/cluster2/home/futing/Project/panCancer/GBM/GSE162976/mcool2cool-%j.log
#SBATCH -J "mcool2cool"

dir=$1
cell=$(basename ${dir})
cd ${dir}

source activate ~/miniforge3/envs/juicer
resolutions=(5000 10000 25000 50000 100000 250000 500000 1000000 2500000)

for resolution in "${resolutions[@]}"; do
	~/miniforge3/envs/juicer/bin/python \
	/cluster2/home/futing/Project/panCancer/scripts/add_prefix_to_cool.py \
	./cool/"${cell}".mcool::resolutions/${resolution}
	echo -e "Dumping resolution $resolution to cool..."
	sh /cluster2/home/futing/Project/panCancer/scripts/mcool2cool_single.sh \
		"$resolution" ./cool/"${cell}".mcool ./cool
done

sh /cluster2/home/futing/Project/panCancer/scripts/juicerv1_p.sh \
	-d ${dir} \
	-s "post" \
	-e "Arima"
