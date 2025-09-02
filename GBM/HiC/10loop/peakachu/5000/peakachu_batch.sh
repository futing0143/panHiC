#!/bin/bash

source /cluster/home/futing/miniforge-pypy3/etc/profile.d/conda.sh
conda activate peakachu
cd /cluster/home/futing/Project/GBM/HiC/10loop/peakachu/5000
## 01 查看是否都有chr前缀和是否balance过，depth查看深度
cat /cluster/home/futing/Project/GBM/HiC/02data/04mcool/name.txt | while read name; do
    echo -e "\nProcessing ${name}...\n"
#    hicInfo -m /cluster/home/tmp/GBM/HiC/02data/03cool/5000/${col_name}.5000.cool
    echo ${name} >> ./depth/batch_5kb.txt
    peakachu depth -p "/cluster/home/tmp/GBM/HiC/02data/03cool/5000/${name}_5000.cool" >> ./depth/batch_5kb.txt
done

##2.0提取每个样本的depth
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
}' ./depth/batch_5kb.txt > ./depth/batch_5kb_clean.txt


##3.0下载pre-trained model
# awk -F'\t' '{printf "wget -c http://3dgenome.fsm.northwestern.edu/peakachu/high-confidence.%s.5kb.w6.pkl\n", $2}' file_depth.txt | sort | uniq > download2.sh
# sh download.sh


###4.0 run peakachu
cat ./depth/batch_5kb_clean.txt | while read i
do
    echo "Processing ${i}..."
    name=$(echo ${i} | awk '{print $1}')
    depth=$(echo ${i} | awk '{print $2}')
    peakachu score_genome -r 5000 --clr-weight-name weight -p /cluster/home/tmp/GBM/HiC/02data/03cool/5000/${name}_5000.cool \
        -O ${name}-peakachu-5kb-scores.bedpe \
        -m /cluster/home/futing/Project/GBM/HiC/10loop/peakachu/peakachu/high-confidence.${depth}.5kb.w6.pkl
    peakachu pool -r 5000 -i ${name}-peakachu-5kb-scores.bedpe -o ${name}-peakachu-5kb-loops.0.95.bedpe -t 0.95
done


