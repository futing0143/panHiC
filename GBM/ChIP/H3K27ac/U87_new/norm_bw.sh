#!/bin/bash

cd /cluster/home/futing/Project/GBM/ChIP/H3K27ac/U87_new
# 设置输入 BAM 文件和输出 BigWig 文件名

TEMP_BW="U87.bw"
BEDGRAPH="/cluster/home/futing/Project/GBM/ChIP/H3K27ac/U87_new/macs2/sorted_output.bedGraph"
TEMP_BEDGRAPH="temp.bedgraph"
OUTPUT_BW="U87_norm_H3K27ac.bw"


# 1. 获取最大覆盖度值
echo "Calculating max coverage value..."
MAX_VAL=$(awk '{if($4>max) max=$4} END{print max}' $BEDGRAPH)

# MAX_VAL=$(bigWigInfo $TEMP_BW | grep "maxVal" | awk '{print $2}')

# 2. 计算归一化因子 scaleFactor
if (( $(echo "$MAX_VAL > 0" | bc -l) )); then
    SCALE_FACTOR=$(echo "1 / $MAX_VAL" | bc -l)
	echo "------------------------"
    echo "Max coverage value: $MAX_VAL"
    echo "Calculated scaleFactor: $SCALE_FACTOR"

    # 4. 生成归一化后的 BigWig 文件
    echo "Generating normalized BigWig file..."
	awk -v max="$MAX_VAL" 'BEGIN{OFS="\t"} {print $1, $2, $3, $4/max}' $BEDGRAPH > $TEMP_BEDGRAPH
	bedGraphToBigWig $TEMP_BEDGRAPH \
		/cluster/home/futing/ref_genome/hg38_25.genome $OUTPUT_BW

    echo "Normalized BigWig file saved as $OUTPUT_BW"
else
    echo "Error: maxVal is zero or undefined. Check your input BAM file."
fi

# 5. 删除临时文件
# rm -f "$TEMP_BW"

# method 2
# computeMatrix scale-regions -S U87.bw -R genes.bed -o matrix.gz
# plotProfile -m matrix.gz --perGroup --outFileName U87_normalized.png --yMin 0 --yMax 1