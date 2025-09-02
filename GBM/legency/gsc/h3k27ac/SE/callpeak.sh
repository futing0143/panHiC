#!/bin/bash

outdir="./macs2"

# 读取input.txt文件的每一行
cat input.txt | while read -r line; do
    # 使用awk分割行，分别获取目标样本和对照样本的标识符
    h3k27ac=$(echo "$line" | awk '{print $1}')
    none=$(echo "$line" | awk '{print $2}')
    
    # 运行MACS2命令
    macs2 callpeak -t "./bam_files/${h3k27ac}.rmdup_sorted.bam" \
                    -c "./bam_files/${none}.rmdup_sorted.bam" \
                    -g hs -f BAM \
                    -n "${h3k27ac}" \
                    --outdir "$outdir" \
                    --broad --broad-cutoff 0.05
    
    # 检查MACS2命令是否执行成功
    if [ $? -eq 0 ]; then
        echo "MACS2 command executed successfully for ${h3k27ac}"
        # 复制peak文件，将默认的Peak文件重命名为macs2peak.bed
        cp "${outdir}/${h3k27ac}_peaks.broadPeak" "${outdir}/${h3k27ac}_macs2peak.bed"
    else
        echo "MACS2 command failed for ${h3k27ac}"
    fi
done
