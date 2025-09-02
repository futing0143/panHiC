#!/bin/bash
reso=$1
name=$2

source /cluster/home/futing/miniforge-pypy3/etc/profile.d/conda.sh
conda activate peakachu
topdir=/cluster/home/futing/Project/GBM/HiC/02data/03cool_order
coolfile="${topdir}/${reso}/${name}_${reso}.cool"

cd /cluster/home/futing/Project/GBM/HiC/10loop/peakachu/${reso}/results
# calculate depth
if [ -f ../depth/${name}_$((reso / 1000))kb_clean.txt ];then
    echo "${name}_$((reso / 1000))kb_clean.txt exists, skip..."
else
    echo "${name}" > ../depth/${name}_$((reso / 1000))kb.txt
    peakachu depth -p ${coolfile} >> ../depth/${name}_$((reso / 1000))kb.txt
    awk '
    {
        if (NR % 28 == 1) {
            line1 = $0
        } else if (NR % 28 == 0) {
            model = $0
            sub(/^.*: /, "", model)  # 移除 "suggested model: " 部分，包括冒号后的空格
            sub(/ million/, "million", model)  # 移除 " million" 前的空格
            sub(/ billion/, "billion", model)  # 移除 " billion" 前的空格
            OFS = "\t"  # 设置输出字段分隔符为制表符
            print line1, model  # 使用逗号分隔变量，避免默认空格
        }
    }' ../depth/${name}_$((reso / 1000))kb.txt > ../depth/${name}_$((reso / 1000))kb_clean.txt
fi

if [ $? -ne 0 ]; then
    echo "***! Problem while running peakachu depth";
    exit 1
fi

# running peakachu
while read -r file depth; do
    echo "Processing ${file} at ${depth}..."
    if [ -f ${file}-peakachu-$((reso / 1000))kb-scores.bedpe ];then
        echo "${file}-peakachu-$((reso / 1000))kb-scores.bedpe exists, skip..."
        continue
    else
        peakachu score_genome -r ${reso} --clr-weight-name weight \
            -p "${topdir}/${reso}/${file}_${reso}.cool" \
            -O ${file}-peakachu-$((reso / 1000))kb-scores.bedpe \
            -m /cluster/home/futing/Project/GBM/HiC/10loop/peakachu/peakachu/high-confidence.${depth}.$((reso / 1000))kb.w6.pkl
    fi
    peakachu pool -r ${reso} \
        -i ${file}-peakachu-$((reso / 1000))kb-scores.bedpe \
        -o ${file}-peakachu-$((reso / 1000))kb-loops.0.95.bedpe -t 0.95
done < "../depth/${name}_$((reso / 1000))kb_clean.txt"

if [ $? -eq 0 ]; then
    echo -e "Peakachu finished successfully for ${name} at ${reso} resolution!!!\n"
else
    echo "***! Problem while running peakachu";
    exit 1
fi