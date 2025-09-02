#!/bin/bash

source activate ~/anaconda3/envs/hic
mcool_dir=/cluster/home/futing/Project/GBM/HiC/02data/04mcool

resolutions=(5000 10000 25000 50000 100000 250000 500000 1000000 2500000)
:<<'END'
# 01 find all the unorderd cool files
for resolution in ${resolutions[@]};do
    cat /cluster/home/futing/Project/GBM/HiC/02data/04mcool/name_all.txt | while read name;do
        echo -e "Processing ${name} at ${resolution} resolution..."
        read -r -d '' mcool_file < <(find -L "${mcool_dir}" -type f -name "${name}.mcool" -print0)
        python /cluster/home/futing/Project/GBM/HiC/02data/05file_transform/compare_chr.py \
            ${mcool_file}::/resolutions/${resolution} >> ${mcool_dir}/qc/diffchrom/${resolution}.txt
    done
done

resolution=100000
cat /cluster/home/futing/Project/GBM/HiC/02data/04mcool/name_all.txt | while read name;do
    echo -e "Processing ${name} at ${resolution} resolution..."
    read -r -d '' mcool_file < <(find -L "${mcool_dir}" -type f -name "${name}.mcool" -print0)
    python /cluster/home/futing/Project/GBM/HiC/02data/05file_transform/compare_chr.py \
        ${mcool_file}::/resolutions/${resolution} >> ${mcool_dir}/${resolution}.txt
done
END

# after add_chr , check it again

for resolution in ${resolutions[@]};do
    cat /cluster/home/futing/Project/GBM/HiC/02data/04mcool/name_all.txt | while read name;do
        echo -e "Processing ${name} at ${resolution} resolution..."
        read -r -d '' mcool_file < <(find -L "${mcool_dir}" -type f -name "${name}.mcool" -print0)
        python /cluster/home/futing/Project/GBM/HiC/02data/05file_transform/compare_chr.py \
            ${mcool_file}::/resolutions/${resolution} >> ${mcool_dir}/qc/diffchrom_after/${resolution}.txt
    done
done