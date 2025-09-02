#!/bin/bash

resolutions=(50000 100000 500000 1000000)
mcool_dir=/cluster/home/futing/Project/GBM/HiC/02data/04mcool
cd /cluster/home/futing/Project/GBM/HiC/02data/04mcool/scripts
for resolution in ${resolutions[@]};do
    cat ./addchrom/${resolution}.txt | while read name;do
        echo -e "\nProcessing ${name} at ${resolution} resolution...\n"

        read -r -d '' mcool_file < <(find -L "${mcool_dir}" -type f -name "${name}.mcool" -print0)
        python /cluster/home/futing/Project/GBM/HiC/02data/05file_transform/add_prefix_to_cool.py \
            ${mcool_file}::resolutions/${resolution}

    done
done