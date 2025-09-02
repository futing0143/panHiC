#!/bin/bash
source /cluster/home/futing/miniforge-pypy3/etc/profile.d/conda.sh
conda activate peakachu
topdir=/cluster/home/futing/Project/GBM/HiC/02data/03cool_order

for file in GBM;do
    echo -e "\nProcessing $file...\n"

    #10000
    cd /cluster/home/futing/Project/GBM/HiC/10loop/peakachu/10000/results_new
    # echo "GBM" > depth_GBM.txt
    # peakachu depth -p "${topdir}/10000/${file}_10000.cool" >> depth_GBM.txt
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
    }' depth_GBM.txt > file_depth_GBM.txt
    
    cat file_depth_GBM.txt | while read i
    do
        echo "Processing ${i}..."
        name=$(echo ${i} | awk '{print $1}')
        depth=$(echo ${i} | awk '{print $2}')
        peakachu score_genome -r 10000 --clr-weight-name weight \
            -p ${topdir}/10000/${file}_10000.cool \
            -O ${name}-peakachu-10kb-scores.bedpe \
            -m /cluster/home/futing/Project/GBM/HiC/10loop/peakachu/peakachu/high-confidence.${depth}.10kb.w6.pkl
        peakachu pool -r 10000 -i ${name}-peakachu-10kb-scores.bedpe -o ${name}-peakachu-10kb-loops.0.95.bedpe -t 0.95
    done

    # 02 5000
    cd /cluster/home/futing/Project/GBM/HiC/10loop/peakachu/5000/result
    # echo "GBM" > depth_GBM.txt
    # peakachu depth -p "${topdir}/5000/${file}_5000.cool" >> depth_GBM.txt
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
    }' depth_GBM.txt > file_depth_GBM.txt
    cat file_depth_GBM.txt | while read i
    do
        echo "Processing ${i}..."
        name=$(echo ${i} | awk '{print $1}')
        depth=$(echo ${i} | awk '{print $2}')
        peakachu score_genome -r 5000 --clr-weight-name weight \
            -p ${topdir}/5000/${file}_5000.cool \
            -O ${name}-peakachu-5kb-scores.bedpe \
            -m /cluster/home/futing/Project/GBM/HiC/10loop/peakachu/peakachu/high-confidence.${depth}.5kb.w6.pkl
        peakachu pool -r 5000 -i ${name}-peakachu-5kb-scores.bedpe -o ${name}-peakachu-5kb-loops.0.95.bedpe -t 0.95
    done
done


