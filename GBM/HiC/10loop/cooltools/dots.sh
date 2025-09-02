#!/bin/bash
filelist=$1
resolutions=(5000 10000 25000)
top_folder=/cluster/home/futing/Project/GBM/HiC/02data/04mcool/
source activate ~/anaconda3/envs/hic
cd /cluster/home/futing/Project/GBM/HiC/10loop/cooltools

cat ${filelist} | while read prefix;do
    # 使用find命令递归搜索匹配的文件
    read -r -d '' mcool_file < <(find -L "$top_folder" -type f -name "${prefix}.mcool" -print0)
    name=$(basename $mcool_file .mcool)
    mkdir -p $name
    cd $name
    echo -e "\nProcessing $name...\n"
    python /cluster/home/futing/Project/GBM/HiC/10loop/cooltools/view_hg38.py -i ${mcool_file}::resolutions/10000 -n $name

    for resolution in "${resolutions[@]}";do
        echo -e "\nRunning expected-cis...\n"
        cooltools expected-cis --nproc 10 -o ./expected.cis.${resolution}.tsv \
            --view ./${name}_view_hg38.tsv ${mcool_file}::resolutions/${resolution}
        
        echo -e "\nRunning dots...\n"
        cooltools dots --nproc 10 -o ./dots.${resolution}.tsv --view ./${name}_view_hg38.tsv \
            ${mcool_file}::resolutions/${resolution} ./expected.cis.${resolution}.tsv 
    done
    cd ..

done 
