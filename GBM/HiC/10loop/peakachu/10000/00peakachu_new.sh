#!/bin/bash

# 这是因为00peakachu.sh用的是KR的数据，这里使用order的数据  

source /cluster/home/futing/miniforge-pypy3/etc/profile.d/conda.sh
conda activate peakachu
cd /cluster/home/futing/Project/GBM/HiC/10loop/peakachu/10000
mkdir results_new
cd /cluster/home/futing/Project/GBM/HiC/10loop/peakachu/10000/results_new

## 01 查看depth查看深度
cat /cluster/home/futing/Project/GBM/HiC/02data/04mcool/name_all.txt | while read name; do
    echo -e "\nProcessing ${name}...\n"
    echo ${name} >> depth_10kb.txt
    peakachu depth -p "/cluster/home/futing/Project/GBM/HiC/02data/03cool_order/10000/${name}_10000.cool" >> depth_10kb.txt
done

##2.0提取每个样本的depth
awk '
{
    if (NR % 28 == 1) {
        line1 = $0
    } else if (NR % 28 == 0) {
        model = $0
        sub(/^.*: /, "", model)      # 移除 "suggested model: " 部分，包括冒号后的空格
        sub(/ million/, "million", model)  # 移除 " million" 前的空格
        sub(/ billion/, "billion", model)  # 移除 " billion" 前的空格
        OFS = "\t"  # 设置输出字段分隔符为制表符
        print line1, model  # 使用逗号分隔变量，避免默认空格
    }
}' depth_10kb.txt > file_depth.txt

###4.0 run peakachu
cat file_depth.txt  | while read i
do
    echo "Processing ${i}..."
    name=$(echo ${i} | awk '{print $1}')
    depth=$(echo ${i} | awk '{print $2}')
    peakachu score_genome -r 10000 --clr-weight-name weight -p /cluster/home/tmp/GBM/HiC/02data/03cool_order/10000/${name}_10000.cool \
        -O ${name}-peakachu-10kb-scores.bedpe \
        -m /cluster/home/futing/Project/GBM/HiC/10loop/peakachu/peakachu/high-confidence.${depth}.10kb.w6.pkl
    peakachu pool -r 10000 -i ${name}-peakachu-10kb-scores.bedpe -o ${name}-peakachu-10kb-loops.0.95.bedpe -t 0.95
done


