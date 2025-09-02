#!/bin/bash

resolutions=(5000 10000 50000 100000 500000 1000000)


# hicCorrectMatrix correct --matrix /cluster/home/futing/Project/GBM/HiC/02data/03cool_KR/merged_50000.cool  \
#         --correctionMethod KR --outFileName  /cluster/home/futing/Project/GBM/HiC/02data/03cool_KR/merged_50000.KR.cool \
#         --filterThreshold -1.5 5.0 \
#         --chromosomes chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chrX 


# cooltools insulation /cluster/home/futing/Project/GBM/HiC/02data/03cool/10000/iPSC_new_10000.cool \
# -o /cluster/home/futing/Project/GBM/HiC/09insulation/insul_futing/10k_50k/iPSC_new_insul.tsv  --ignore-diags 2 --verbose 500000

cd /cluster/home/futing/Project/GBM/HiC/09insulation/10k_50k
data_dir=/cluster/home/futing/Project/GBM/HiC/02data/03cool_order/${resolutions[1]}
result_dir=/cluster/home/futing/Project/GBM/HiC/09insulation/10k_50k/result
mkdir -p ${result_dir}

#cat /cluster/home/futing/Project/GBM/HiC/02data/04mcool/name_all.txt | while read i;do
for i in GBM A172_2 astro1 astro2 OPC;do
    name=${data_dir}/${i}_${resolutions[1]}.cool
    echo -e "Processing ${name} ...\n"
    
    cooltools insulation ${name} 50000 -o ${result_dir}/${i}_insul.tsv  --ignore-diags 2 --verbose

done

sh /cluster/home/futing/Project/GBM/HiC/09insulation/postprocess.sh BS_10k_sup_50k.tsv ${result_dir} 8
sh /cluster/home/futing/Project/GBM/HiC/09insulation/postprocess.sh insul_10k_sup_50k.tsv ${result_dir} 6

:<<'END'
output_file="isB_50k.tsv"

# 初始化输出文件为空
> $output_file

# 遍历文件夹中的每个 .tsv 文件
for file in /cluster/home/futing/Project/GBM/HiC/09insulation/insul_futing/10k_50k/*.tsv; do
    col_name=$(basename "$file" _insul.tsv)
    # 将列标题添加到临时文件 \t${col_name}_is_boundary
    echo -e "${col_name}" > temp_col.tsv
    
    # 6: log2_insulation_score_800000 8:boundary_strength_800000 9:is_boundary_800000
    awk 'BEGIN {OFS=FS="\t"} NR > 1 {print $9}' "$file" >> temp_col.tsv
    
    # 如果输出文件为空，则直接赋值
    if [ ! -s $output_file ]; then
        cp temp_col.tsv $output_file
    else
        # 使用 paste 将新列添加到输出文件
        paste $output_file temp_col.tsv > temp_combined.tsv
        mv temp_combined.tsv $output_file
    fi
done

# 删除临时文件
rm temp_col.tsv
END