#!/bin/bash

# 设置输入 BAM 文件和输出 BigWig 文件名
name=$1
cd /cluster/home/futing/Project/GBM/RNA/sample/20240830/analysis/${name}

date

# 01 生成临时 BigWig 文件
echo "Generating temporary BigWig file..."
bamCoverage -b ${name}.bam -o ${name}.bw
bamCoverage -b ${name}.bam -o "${name}_RPKM.bw" --normalizeUsing RPKM


# 02 获取最大覆盖度值
echo "Calculating max coverage value..."
# bigWigToBedGraph ${name}.bw temp.bedgraph
# MAX_VAL=$(awk '{if($4>max) max=$4} END{print max}' temp.bedgraph)

MAX_VAL=$(bigWigInfo ${name}.bw | grep "max" | awk '{print $2}')

# 03 生成文件
if (( $(echo "$MAX_VAL > 0" | bc -l) )); then
    SCALE_FACTOR=$(echo "1 / $MAX_VAL" | bc -l)
	echo "-----------------------------"
    echo "Max coverage value: $MAX_VAL"
    echo "Calculated scaleFactor: $SCALE_FACTOR"

    # 4. 生成归一化后的 BigWig 文件
    echo "Generating normalized BigWig file..."
    bamCoverage -b ${name}.bam -o "${name}_norm.bw" --scaleFactor "$SCALE_FACTOR"
	bamCoverage -b ${name}.bam -o "${name}_norm_RPKM.bw" --normalizeUsing RPKM \
		--scaleFactor "$SCALE_FACTOR"
    echo "Normalized BigWig file saved as ${name}_norm.bw"
else
    echo "Error: maxVal is zero or undefined. Check your input BAM file."
fi


# method 2
# computeMatrix scale-regions -S U87.bw -R genes.bed -o matrix.gz
# plotProfile -m matrix.gz --perGroup --outFileName U87_normalized.png --yMin 0 --yMax 1