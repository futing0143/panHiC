#!/bin/bash


cd /cluster/home/futing/Project/GBM/ChIP/H3K27ac/NPC2
source activate HiC
name=NPC
rep1=/cluster/home/futing/Project/GBM/ChIP/H3K27ac/NPC2/macs2/SRR17882758_peaks.narrowPeak
rep2=/cluster/home/futing/Project/GBM/ChIP/H3K27ac/NPC2/macs2/SRR17882759_peaks.narrowPeak
BEDGRAPH="./macs2/sorted_output.bedGraph"
TEMP_BEDGRAPH="./macs2/temp.bedgraph"
OUTPUT_BW="NPC_norm_H3K27ac.bw"

# 01 合并两个样本的 peak	
# sort
sort -k8,8nr ${rep1} > ./macs2/rep1_sorted.narrowPeak
sort -k8,8nr ${rep2} > ./macs2/rep2_sorted.narrowPeak
# idr
idr --samples ./macs2/rep1_sorted.narrowPeak ./macs2/rep2_sorted.narrowPeak \
        --input-file-type narrowPeak \
        --peak-merge-method avg \
        --output-file ./macs2/${name}-idr.bed \
        --plot \
        --log-output-file ./macs2/rep1_rep2_idr.log

# 02 extract bedgraph
awk -F '\t' 'BEGIN {FS=OFS="\t"}{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10}' ./macs2/${name}-idr.bed > ./macs2/${name}_idr_merge.bed 
awk 'BEGIN{OFS="\t"} {print $1, $2, $3, $7}' ./macs2/${name}_idr_merge.bed > ./macs2/output.bedGraph
LC_ALL=C sort -k1,1 -k2,2n ./macs2/output.bedGraph > ./macs2/sorted_output.bedGraph #sort bedGraph

# 03 convert bedgraph to bigwig
# bedGraphToBigWig ./macs2/sorted_output.bedGraph \
	# /cluster/home/futing/ref_genome/hg38.chrom.sizes ./macs2/U87_H3K27ac.bw

# -- scaling bedgraph to bigwig
echo "Calculating max coverage value..."
MAX_VAL=$(awk '{if($4>max) max=$4} END{print max}' $BEDGRAPH)


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
