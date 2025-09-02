#!/bin/bash

name=NPC

# 设置输入 BAM 文件和输出 BigWig 文件名
BAM_FILE="${name}.bam"
TEMP_BW="${name}.bw"
OUTPUT_BW="${name}_normalized.bw"
cd /cluster/home/futing/Project/GBM/RNA/sample/NPC


# 1. 生成临时 BigWig 文件
echo -e "Generating temporary BigWig file...\n"
# bamCoverage -b "$BAM_FILE" -o "$TEMP_BW"
bamCoverage -b "${name}.bam" -o ${name}_RPKM.bw --normalizeUsing RPKM

# 2. 获取最大覆盖度值
echo -e "Calculating max coverage value...\n"
# bigWigToBedGraph $TEMP_BW temp.bedgraph
# MAX_VAL=$(awk '{if($4>max) max=$4} END{print max}' temp.bedgraph)
MAX_VAL=$(bigWigInfo $TEMP_BW | grep "max" | awk '{print $2}')

# 3. 计算归一化因子 scaleFactor
if (( $(echo "$MAX_VAL > 0" | bc -l) )); then
    SCALE_FACTOR=$(echo "1 / $MAX_VAL" | bc -l)
    echo "Max coverage value: $MAX_VAL"
    echo "Calculated scaleFactor: $SCALE_FACTOR"

    # 4. 生成归一化后的 BigWig 文件
    echo "Generating normalized BigWig file..."
    bamCoverage -b "$BAM_FILE" -o "$OUTPUT_BW" \
		--scaleFactor "$SCALE_FACTOR" #--numberOfProcessors 10 
    bamCoverage -b "$BAM_FILE" -o "NPC_norm_RPKM.bw" --normalizeUsing RPKM \
		--scaleFactor "$SCALE_FACTOR"

    echo "Normalized BigWig file saved as $OUTPUT_BW"
else
    echo "Error: maxVal is zero or undefined. Check your input BAM file."
fi

# 5. 删除临时文件
# rm -f "$TEMP_BW"
