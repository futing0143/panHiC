#!/bin/bash

source activate ~/anaconda3/envs/peakachu
cd /cluster/home/futing/Project/GBM/HiC/10loop/peakachu/10k

## 01 查看是否都有chr前缀和是否balance过，depth查看深度
for name in G208 G213 42MGBA; do
    echo -e "\nProcessing ${name}...\n"
#    hicInfo -m /cluster/home/tmp/GBM/HiC/02data/03cool/10000/${col_name}.10000.cool
    echo ${name} >> bug_10k.txt
    peakachu depth -p "/cluster/home/tmp/GBM/HiC/02data/03cool/10000/${name}_10000.cool" >> bug_10k.txt
done

## 02 提取每个样本的depth
awk '
{
    if (NR % 28 == 1) {
        line1 = $0
    } else if (NR % 28 == 0) {
        model = $0
        sub(/^.*: /, "", model)  # 移除 "suggested model: " 部分，包括冒号后的空格
        sub(/ million/, "million", model)  # 移除 " million" 前的空格
        OFS = "\t"  # 设置输出字段分隔符为制表符
        print line1, model  # 使用逗号分隔变量，避免默认空格
    }
}' bug_10k.txt > "/cluster/home/futing/Project/GBM/HiC/10loop/peakachu/10000/depth/bug2_10kb_clean.txt"

## 03 下载pre-trained model
# awk -F'\t' '{printf "wget -c http://3dgenome.fsm.northwestern.edu/peakachu/high-confidence.%s.10kb.w6.pkl\n", $2}' bug_depth.txt | sort | uniq > download2.sh
# sh download2.sh


###4.0 run peakachu
cat ./depth/bug2_10kb_clean.txt | while read i
do
    echo "Processing ${i}..."
    name=$(echo ${i} | awk '{print $1}')
    depth=$(echo ${i} | awk '{print $2}')
    peakachu score_genome -r 10000 --clr-weight-name weight -p /cluster/home/tmp/GBM/HiC/02data/03cool_order/10000/${name}_10000.cool \
        -O ${name}-peakachu-10kb-scores.bedpe \
        -m high-confidence.${depth}.10kb.w6.pkl
    peakachu pool -r 10000 -i ${name}-peakachu-10kb-scores.bedpe -o ${name}-peakachu-10kb-loops.0.95.bedpe -t 0.95
done


