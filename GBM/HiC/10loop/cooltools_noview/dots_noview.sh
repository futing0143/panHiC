#!/bin/bash

resolutions=(5000 10000 25000)
top_folder=/cluster/home/futing/Project/GBM/HiC/02data/03cool/
source activate ~/anaconda3/envs/hic
cd /cluster/home/futing/Project/GBM/HiC/10loop/cooltools_noview

#cat /cluster/home/futing/Project/GBM/HiC/02data/04mcool/name.txt | while read prefix;do
for prefix in GBM;do
    mkdir -p ${prefix}
    cd ${prefix}
    for resolution in "${resolutions[@]}";do
            # 使用find命令递归搜索匹配的文件
        cool_file=${top_folder}/${resolution}/${prefix}_${resolution}.cool

        echo -e "\nProcessing ${prefix} at ${resolution}...\n"
        #python /cluster/home/futing/Project/GBM/HiC/10loop/cooltools/view_hg38.py -i ${cool_file} -n ${prefix}

        cooltools expected-cis --nproc 10 -o ./expected.cis.${resolution}.tsv ${cool_file} 
        #    --view ./${name}_view_hg38.tsv 
        cooltools dots --nproc 10 -o ./dots.${resolution}.tsv \
            ${cool_file} ./expected.cis.${resolution}.tsv 

    done
    cd ..

done 