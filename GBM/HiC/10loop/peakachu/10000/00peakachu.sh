#!/bin/bash

# !!! 这个版本用的cool是hicexplorer kr的cool，hicexplorer的命令是有问题的，所有result_KR的结果不可用

##1.0查看是否都有chr前缀和是否balance过，depth查看深度
for file in /cluster/home/tmp/GBM/HiC/02data/03cool_KR/10000/*cool; do
    col_name=$(basename "$file" .10000.KR.cool)
    echo ${col_name}
#    hicInfo -m /cluster/home/tmp/GBM/HiC/02data/03cool_KR/10000/${col_name}.10000.KR.cool
    peakachu depth -p "/cluster/home/tmp/GBM/HiC/02data/03cool_KR/10000/${col_name}.10000.KR.cool"
done

##2.0提取每个样本的depth
awk '
{
    if (NR % 4 == 1) {
        line1 = $0
    } else if (NR % 4 == 0) {
        model = $0
        sub(/^.*: /, "", model)  # 移除 "suggested model: " 部分，包括冒号后的空格
        sub(/ million/, "million", model)  # 移除 " million" 前的空格
        sub(/ billion/, "billion", model)  # 移除 " billion" 前的空格
        OFS = "\t"  # 设置输出字段分隔符为制表符
        print line1, model  # 使用逗号分隔变量，避免默认空格
    }
}' depth_10k.txt > file_depth.txt

##3.0下载pre-trained model
# awk -F'\t' '{printf "wget -c http://3dgenome.fsm.northwestern.edu/peakachu/high-confidence.%s.10kb.w6.pkl\n", $2}' file_depth.txt | sort | uniq > download.sh


###4.0 run peakachu
cat file_depth.txt  | while read i
do
    name=$(echo ${i} | awk '{print $1}')
    depth=$(echo ${i} | awk '{print $2}')
    peakachu score_genome -r 10000 --balance -p /cluster/home/tmp/GBM/HiC/02data/03cool_KR/10000/${name}.10000.KR.cool -O ${name}-peakachu-10kb-scores.bedpe -m high-confidence.${depth}.10kb.w6.pkl
    peakachu pool -r 10000 -i ${name}-peakachu-10kb-scores.bedpe -o ${name}-peakachu-10kb-loops.0.95.bedpe -t 0.95
done


