#!/bin/bash

dir=$1
spe=${2:-}
cell=$(basename $dir)

if [ -z ${spe} ];then
	mcool_file=${dir}/cool/${cell}.mcool
else
	mcool_file=${dir}/cool/${cell}_${spe}.mcool
fi
# log_dir="${dir}/debug"
# mkdir -p "$log_dir"
# exec > "${log_dir}/${cell}_SV-${SLURM_JOB_ID}.log" 2>&1

echo "[$(date)] Starting job ${SLURM_JOB_ID} for ${dir}..."
OS_INFO=$(uname -a)
echo "系统信息: $OS_INFO"

source activate /cluster2/home/futing/miniforge3/envs/eagleC

mkdir -p $dir/anno/SV && cd $dir/anno/SV
ln -s /cluster2/home/futing/Project/panCancer/Analysis/SV/EagleC2-models ${dir}/anno/SV/
if [ -d "$dir/anno/SV/.eaglec2" ];then
	rm -r $dir/anno/SV/.eaglec2
fi



# 01 
if [ ! -e "${mcool_file}" ]; then
	echo "[INFO] ${mcool_file} not found!"
	exit 1
elif [ ! -e "${cell}.SV_calls.txt" ]; then
	for reso in 25000 10000 5000; do
		echo "[INFO] ${mcool_file} not found!"
		file=${mcool_file}::/resolutions/${reso}
		if cooler dump -t bins --header "$file" | head -1 | grep -qw "weight";then
			echo "$file is balanced"
			continue
		else
			echo "[$(date)] ${file} is not ICE balanced!"
			cooler balance "$file"
		fi
	done
	echo "[$(date)] Running predictSV for ${cell}..."
	predictSV --mcool ${mcool_file} \
		-O ${cell} -g hg38 --balance-type ICE -p 15

else
	echo -e "[INFO] ${cell}.SV_calls.txt already exists, skipping."
fi

# 02
if [ ! -e "${cell}.SV_calls.txt" ];then
	echo "[INFO] ${cell}.SV_calls.txt doesn't exits!"
	exit 1
elif [ ! -e "${cell}.SV_calls.reformat.txt" ];then
	echo "[$(date)] Running reformatSV for ${cell}..."
	reformatSV --input ${cell}.SV_calls.txt \
		--output-file ${cell}.SV_calls.reformat.txt
fi

# 03
source activate /cluster2/home/futing/miniforge3/envs/neoloop

if [ ! -e "${cell}.SV_calls.reformat.txt" ]; then
	echo "[INFO] ${cell}.SV_calls.reformat.txt not found!"
	exit 1
elif [ ! -e "${cell}.assemblies.txt" ]; then
	echo "[$(date)] Running assemble-complexSVs for ${cell}..."
	assemble-complexSVs -O ${cell} \
		-B ${cell}.SV_calls.reformat.txt \
		--balance-type ICE --protocol insitu \
		--nproc 15 \
		-H ${mcool_file}::/resolutions/50000 \
		${mcool_file}::/resolutions/10000 \
		${mcool_file}::/resolutions/5000
else
	echo -e "[INFO] ${cell}.assemblies.txt already exists, skipping assemble-complexSVs....\n"
fi

# 04
if [ ! -e "${cell}.assemblies.txt" ]; then
	echo "[INFO] ${cell}.assemblies.txt not found!"
	exit 1
elif [ ! -e "${cell}.neo-loops.txt" ]; then
	for reso in 50000 10000 5000; do
		file=${mcool_file}::/resolutions/${reso}
		if cooler dump -t bins --header "$file" | head -1 | grep -qw "weight";then
			echo "$file is balanced"
			continue
		else
			echo "[$(date)] ${file} is not ICE balanced!"
			cooler balance "$file"
		fi
	done

	echo "[$(date)] Running neoLoop-caller for ${cell}..."
	neoloop-caller -O ${cell}.neo-loops.txt \
		--assembly ${cell}.assemblies.txt \
		--balance-type ICE \
		--protocol insitu \
		--prob 0.95 --nproc 15 \
		-H ${mcool_file}::/resolutions/50000 \
		${mcool_file}::/resolutions/10000 \
		${mcool_file}::/resolutions/5000

else
	echo -e "[INFO] ${cell}.neo-loops.txt already exists, skipping neoLoop-caller....\n"
fi