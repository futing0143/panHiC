#!/bin/bash

#cooltools genome binnify /cluster/home/jialu/genome/hg38.chrom.sizes 500000 >500k_bin.txt
#cooltools genome gc 500k_bin.txt ~/../../share/ref_genome/hg38/assembly/hg38.fa > gc_500k.txt
source /cluster/home/futing/miniforge-pypy3/etc/profile.d/conda.sh
conda activate hic

cd /cluster/home/futing/Project/GBM/HiC/06compartment/cooltools/500k
#cat /cluster/home/tmp/GBM/HiC/02data/03cool_order/name_all.txt | while read i

#for i in A172_2 astro1 astro2; 
for i in OPC;
do
    echo -e "Processing ${i} ...\n"
    cooltools eigs-cis \
        --phasing-track /cluster/home/futing/Project/GBM/HiC/06compartment/cooltools/gc_500k.txt \
        /cluster/home/tmp/GBM/HiC/02data/03cool_order/500000/${i}_500000.cool \
        --out-prefix ./${i}_cis_500k

    if [ $? -eq 0 ];then
        continue
    else
        echo -e "Failed: ${i}!!!\n"
    fi
done

#02 get eigenvector into one file

output_file="/cluster/home/futing/Project/GBM/HiC/06compartment/cooltools/E1_500k_1105.tsv"
first_file=true
>"$output_file"
for file in /cluster/home/futing/Project/GBM/HiC/06compartment/cooltools/500k/*.vecs.tsv; do
    colname=$(basename "$file" _cis_500k.cis.vecs.tsv)
    echo -e "$colname" > temp_col.tsv
    # 提取第五列内容（跳过标题行）
    tail -n +2 "$file" | cut -f5 >> temp_col.tsv
    
    if [ "$first_file" = true ]; then
        # 第一次运行时直接将内容写入 output_file，不添加空列
        cp temp_col.tsv $output_file
        first_file=false
    else
        # 之后使用 paste 合并，避免引入空列
        paste $output_file temp_col.tsv > temp_combined.tsv
        mv temp_combined.tsv $output_file
    fi
done

rm temp_col.tsv


if [ $? -eq 0 ]; then
    echo -e "----- Done -----\n"
else
    echo "Failed"
fi