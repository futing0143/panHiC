#!/bin/bash

resolutions=(5000 10000 25000 50000 100000 250000 500000 1000000 2500000)
mcool_dir=/cluster/home/futing/Project/GBM/HiC/02data/04mcool

cat /cluster/home/futing/Project/GBM/HiC/02data/04mcool/name_all.txt | while read name;do
    for resolution in ${resolutions[@]};do
        echo -e "Processing ${name} at ${resolution} resolution..."
        read -r -d '' mcool_file < <(find -L "${mcool_dir}" -type f -name "${name}.mcool" -print0)
        if hicInfo -m ${mcool_file}::resolutions/${resolution} | grep 'weight'; then
            echo "Found 'weight' in the ${mcool_file}."
        else
            # 如果没有找到 'weight'，执行的操作
            echo "'weight' not found."
            cooler balance ${mcool_file}::resolutions/${resolution}
        fi
    done

done