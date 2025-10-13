#!/bin/bash
#SBATCH --cpus-per-task=10
#SBATCH --nodelist=node4
#SBATCH --output=/cluster2/home/futing/Project/panCancer/check/debug/calres-%j.log
#SBATCH -J "calres"

source activate /cluster2/home/futing/miniforge3/envs/juicer

IFS=$'\t'
while read -r cancer gse cell;do
	date
    echo -e "${cancer}\t${gse}\t${cell}\n"
    dir=/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}
    cd ${dir} || { echo "无法进入目录: ${dir}"; continue; }
    if [[ -f "${dir}/aligned/merged_nodups.txt" ]]; then
        input_file="${dir}/aligned/merged_nodups.txt"
    elif [[ -f "${dir}/aligned/merged_nodups.txt.gz" ]]; then
        echo "临时解压文件: ${dir}/aligned/merged_nodups.txt.gz"
        temp_file=$(mktemp)
        gunzip -c "${dir}/aligned/merged_nodups.txt.gz" > "${temp_file}"
        input_file="${temp_file}"
    else
        echo "错误：找不到 merged_nodups 文件，跳过 ${cancer} ${gse} ${cell}"
        continue
    fi
    
    /cluster2/home/futing/software/juicer-1.6/misc/calculate_map_resolution.sh \
        "${input_file}" \
        "${dir}/aligned/50bp.txt"
    
    if [[ -n "${temp_file}" && -f "${temp_file}" ]]; then
        rm "${temp_file}"
    fi

done < <(grep 'inter_30.hic' /cluster2/home/futing/Project/panCancer/check/hic/hicdone1012nig.txt | cut -f1-3)